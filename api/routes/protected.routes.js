import express from 'express';
import { authenticateToken, requireRole } from '../middleware/auth.js';
import { return200 } from '../util/index.js';

const router = express.Router();

router.get('/profile', authenticateToken, (req, res) => {
    return200(
        {
            message: 'Profile accessed successfully',
            user: req.user,
        },
        res
    );
});

router.get('/driver-only', authenticateToken, requireRole('driver'), (req, res) => {
    return200(
        {
            message: 'Driver area accessed successfully',
            user: req.user,
        },
        res
    );
});

// Example of route that requires customer role
router.get('/customer-only', authenticateToken, requireRole('customer'), (req, res) => {
    return200(
        {
            message: 'Customer area accessed successfully',
            user: req.user,
        },
        res
    );
});

export default router;
