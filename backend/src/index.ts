import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import fs from 'fs';
import path from 'path';
import multer from 'multer';
import authRoutes from './routes/auth.route';
import adminRoutes from './routes/admin.route';
import activityLogRoutes from './routes/activity-log.route';
import otpRoutes from './routes/otp.route';
import productRoutes from './routes/product.route';
import productsPublicRoutes from './routes/products-public.route';
import orderRoutes from './routes/order.route';
import reviewRoutes from './routes/review.route';
import chatRoutes from './routes/chat.route';

const app = express();

// Create uploads directory if it doesn't exist
const uploadsDir = path.join(process.cwd(), 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

app.use(cors({
  origin: ['http://localhost:3000', 'http://192.168.1.66:3000', 'http://10.0.2.2:5000', 'http://localhost:5000'],
  credentials: true
}));
app.use(express.json());
app.use('/uploads', express.static('uploads'));
app.use('/admin-panel', express.static(path.join(process.cwd(), 'public')));
app.use('/api/auth', authRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/admin/activity-logs', activityLogRoutes);
app.use('/api/admin/products', productRoutes);
app.use('/api/products', productsPublicRoutes);
app.use('/api/otp', otpRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/reviews', reviewRoutes);
app.use('/api/chat', chatRoutes);

// Global error handler — ensures JSON responses for multer and other errors
app.use((err: any, _req: Request, res: Response, _next: NextFunction) => {
  if (err instanceof multer.MulterError) {
    return res.status(400).json({ message: `Upload error: ${err.message}` });
  }
  return res.status(err.statusCode || 500).json({
    message: err.message || 'Internal server error',
  });
});

export default app;
