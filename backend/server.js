const express = require("express");
const session = require("express-session");
const path = require("path");
const methodOverride = require("method-override");

const app = express();
const port = 3000;

// Import file db.js
const db = require("./db");
db.connect();

// Cấu hình session
app.use(
  session({
    secret: "ban-muon-gi-cung-duoc",
    resave: false,
    saveUninitialized: false,
    cookie: {
      maxAge: 1000 * 60 * 60 * 24, // 1 ngày
      secure: false,
      httpOnly: true,
    },
  })
);

// Cấu hình middleware
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(methodOverride("_method"));
app.use("/uploads", express.static(path.join(__dirname, "public/uploads")));

// Import route controller (chỉnh lại đường dẫn đúng)
const homeController = require("./controllers/homeController");
const accountController = require("./controllers/accountController");
const adminController = require("./controllers/adminController");
const providerController = require("./controllers/providerController");

// Gắn route vào ứng dụng
app.use("/", homeController);
app.use("/account", accountController);
app.use("/admin", adminController);
app.use("/provider", providerController);

// Khởi động server
app.listen(port, () => {
  console.log(`✅ Server đang chạy tại: http://localhost:${port}`);
});
