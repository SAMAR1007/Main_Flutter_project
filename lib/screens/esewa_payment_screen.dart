import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../core/constants/app_colors.dart';

/// Result returned from the eSewa payment WebView.
class EsewaPaymentResult {
  final bool success;
  final String? encodedData;

  EsewaPaymentResult({required this.success, this.encodedData});
}

/// Custom callback URL scheme used to detect eSewa redirects.
/// These are fake URLs that only exist so the WebView can intercept them.
const _kSuccessUrl = 'https://techhive.app/checkout/success';
const _kFailureUrl = 'https://techhive.app/checkout/failure';

/// Opens the eSewa payment portal in a WebView.
/// Returns [EsewaPaymentResult] with the encoded response data on success.
class EsewaPaymentScreen extends StatefulWidget {
  final String formUrl;
  final Map<String, dynamic> formData;

  const EsewaPaymentScreen({
    super.key,
    required this.formUrl,
    required this.formData,
  });

  @override
  State<EsewaPaymentScreen> createState() => _EsewaPaymentScreenState();
}

class _EsewaPaymentScreenState extends State<EsewaPaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasPopped = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _popWithResult(EsewaPaymentResult result) {
    if (_hasPopped) return;
    _hasPopped = true;
    Navigator.of(context).pop(result);
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) setState(() => _isLoading = true);
            if (kDebugMode) print('[eSewa] Page started: $url');
          },
          onPageFinished: (url) {
            if (mounted) setState(() => _isLoading = false);
            if (kDebugMode) print('[eSewa] Page finished: $url');
            // Check callback on page finish too (some redirects land here)
            _checkForCallback(url);
          },
          onNavigationRequest: (request) {
            if (kDebugMode) {
              print('[eSewa] Navigation request: ${request.url}');
            }
            if (_checkForCallback(request.url)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            if (kDebugMode) {
              print('[eSewa] WebResource error: ${error.description}');
            }
            // The callback URLs (techhive.app) will fail to load as web
            // resources since they're fake — that's expected. The
            // onNavigationRequest or onPageFinished should catch them first,
            // but handle the edge case here too.
            if (error.url != null) {
              _checkForCallback(error.url!);
            }
          },
        ),
      );

    // Load the eSewa form URL directly via POST using the form approach
    // We set a real base URL so the form POST works correctly on Android
    _controller.loadHtmlString(
      _buildAutoSubmitHtml(),
      baseUrl: widget.formUrl,
    );
  }

  /// Check if the URL is a payment callback (success or failure).
  /// Matches by path (/checkout/success or /checkout/failure) so it works
  /// regardless of whether eSewa redirects to the custom domain
  /// (techhive.app) or the backend's fallback URL (localhost:3000).
  bool _checkForCallback(String url) {
    if (_hasPopped) return true;

    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    final path = uri.path;

    if (path == '/checkout/success' || url.startsWith(_kSuccessUrl)) {
      final data = uri.queryParameters['data'];
      if (kDebugMode) {
        print('[eSewa] SUCCESS callback — data present: ${data != null}');
      }
      _popWithResult(EsewaPaymentResult(success: true, encodedData: data));
      return true;
    }

    if (path == '/checkout/failure' || url.startsWith(_kFailureUrl)) {
      if (kDebugMode) print('[eSewa] FAILURE callback');
      _popWithResult(EsewaPaymentResult(success: false));
      return true;
    }

    return false;
  }

  /// Build an HTML page that auto-submits the form data to eSewa's payment URL
  String _buildAutoSubmitHtml() {
    final formFields = StringBuffer();
    widget.formData.forEach((key, value) {
      final escapedValue = const HtmlEscape().convert(value.toString());
      formFields.write(
        '<input type="hidden" name="$key" value="$escapedValue" />\n',
      );
    });

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body {
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      margin: 0;
      font-family: -apple-system, BlinkMacSystemFont, sans-serif;
      background: #f5f5f5;
    }
    .loader {
      text-align: center;
      color: #666;
    }
    .spinner {
      border: 4px solid #e0e0e0;
      border-top: 4px solid #60BB46;
      border-radius: 50%;
      width: 40px;
      height: 40px;
      animation: spin 1s linear infinite;
      margin: 0 auto 16px;
    }
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
  </style>
</head>
<body>
  <div class="loader">
    <div class="spinner"></div>
    <p>Redirecting to eSewa...</p>
  </div>
  <form id="esewaForm" method="POST" action="${widget.formUrl}">
    $formFields
  </form>
  <script>
    window.onload = function() {
      document.getElementById('esewaForm').submit();
    };
  </script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('eSewa Payment'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _popWithResult(EsewaPaymentResult(success: false)),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}
