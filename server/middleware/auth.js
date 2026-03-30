function auth(req, res, next) {
    if (!req.session.userId) return res.status(401).json({ error: "Uzivatel neprihlaseny" });
    next();
}

function adminOnly(req, res, next) {
    if (req.session.role !== "a") return res.status(403).json({ error: "Nedostatocne opravnenia" });
    next();
}

module.exports = {
    auth,
    adminOnly,
};

