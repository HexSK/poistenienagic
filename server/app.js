const express = require("express");
const path = require("path");

const app = express();
const PORT = 3000;

app.use(express.json());

app.get("/*", (req, res) => {
    res.sendFile(path.join(__dirname, "../client/dist/index.html"));
});

app.listen(8080, () => {
    console.log("Server started on port 8080");
});