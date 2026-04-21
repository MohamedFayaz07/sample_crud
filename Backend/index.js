require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// 1. Connect to Supabase
const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_KEY
);

// --- SIGN UP ROUTE ---
app.post('/api/signup', async (req, res) => {
    const { email, password } = req.body;
    try {
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        const { error } = await supabase
            .from('users')
            .insert([{ email: email, password_hash: hashedPassword }]);

        if (error) throw error;
        res.json({ success: true, message: 'User created successfully!' });
    } catch (err) {
        res.status(400).json({ success: false, message: err.message });
    }
});

// --- LOG IN ROUTE ---
app.post('/api/login', async (req, res) => {
    const { email, password } = req.body;
    try {
        const { data: user, error } = await supabase
            .from('users').select('*').eq('email', email).single();

        if (error || !user) return res.status(401).json({ success: false, message: 'Invalid email' });

        const validPassword = await bcrypt.compare(password, user.password_hash);
        if (!validPassword) return res.status(401).json({ success: false, message: 'Invalid password' });

        const token = jwt.sign({ id: user.id, email: user.email }, process.env.JWT_SECRET, { expiresIn: '7d' });

        res.json({ success: true, message: 'Login successful!', token: token });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Server error' });
    }
});

// --- THE SECURITY BOUNCER ---
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) return res.status(401).json({ success: false, message: 'No token provided' });

    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) return res.status(403).json({ success: false, message: 'Invalid token' });
        req.user = user;
        next();
    });
};

// --- GET ITEMS ---
app.get('/api/notes', authenticateToken, async (req, res) => {
    try {
        // Querying 'items' table instead of 'notes'
        const { data, error } = await supabase.from('items').select('*');
        if (error) throw error;
        res.json({ success: true, data: data });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
});

// --- ADD ITEM ---
app.post('/api/notes', authenticateToken, async (req, res) => {
    const { description, user_type } = req.body;
    console.log("Attempting to add to items table:", { description, user_type });
    try {
        const { data, error } = await supabase
            .from('items')
            .insert([{ description, user_type }])
            .select();

        if (error) {
            console.error("Supabase Error:", error);
            throw error;
        }
        res.json({ success: true, data: data[0] });
    } catch (err) {
        console.error("Server Error:", err.message);
        res.status(500).json({ success: false, message: err.message });
    }
});

// --- UPDATE ITEM ---
app.put('/api/notes/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    const { description, user_type } = req.body;
    try {
        const { data, error } = await supabase
            .from('items')
            .update({ description, user_type })
            .eq('id', id)
            .select();
        if (error) throw error;
        res.json({ success: true, data: data[0] });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
});

// --- DELETE ITEM ---
app.delete('/api/notes/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    try {
        const { error } = await supabase
            .from('items')
            .delete()
            .eq('id', id);
        if (error) throw error;
        res.json({ success: true, message: 'Item deleted' });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
});

// Start Server
app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
