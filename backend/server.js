const express = require("express");
const mysql = require("mysql2/promise"); // We're using the promise version for async/await support
const bodyParser = require("body-parser");
const bcrypt = require("bcrypt");
const app = express();

const port = 3000;
const saltRounds = 10;
// MySQL connection pool configuration
const pool = mysql.createPool({
  host: "192.168.56.1",
  user: "root",
  password: "root",
  database: "busses",
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

app.use(express.json()); // Parse JSON requests
app.use(bodyParser.urlencoded({ extended: true }));

// Express route example
app.get("/api/buses", async (req, res) => {
  try {
    const [rows, fields] = await pool.execute("SELECT * FROM bus_info");
    res.json(rows);
  } catch (error) {
    console.error("Error fetching data from MySQL:", error);
    res.status(500).send("Internal Server Error");
  }
});

app.get("/api/buses/q", async (req, res) => {
  try {
    const destination = req.query.destination;

    if (!destination) {
      return res
        .status(400)
        .json({ error: "Destination parameter is required." });
    }

    const [rows, fields] = await pool.execute(
      "SELECT * FROM bus_info WHERE destination = ? and TIME > NOW() ORDER BY TIME LIMIT 5",
      [destination]
    );
    if (rows.length > 0) {
      // If there are matching buses, send the list as a response
      res.json(rows);
    } else {
      // If there are no matching buses, send an appropriate message
      res.json({ message: "No matching buses found for the destination." });
    }
  } catch (error) {
    console.error("Error fetching data from MySQL:", error);
    res.status(500).send("Internal Server Error");
  }
});

app.post("/validate", async (req, res) => {
  const qrCodeData = req.body.qrCodeData || "";
  console.log("Received QR code data:", qrCodeData);

  try {
    const isValid = await isValidTicketId(qrCodeData);
    res.json(isValid);
  } catch (error) {
    console.error("Error during validation:", error);
    res.status(500).send("Internal Server Error");
  }
});

app.post("/createticket", async (req, res) => {
  const ticketid = req.body.ticketid;

  try {
    const connection = await pool.getConnection();

    try {
      // Execute the query to update the database with the new ticketid
      const [result] = await connection.execute(
        "INSERT INTO namma_ticket (Ticket_Id,Validity, User) VALUES (?, 1,?)",
        [ticketid, "default-username"]
      );

      // Check if the query was successful
      if (result.affectedRows === 1) {
        res
          .status(200)
          .json({ success: true, message: "UID updated successfully" });
      } else {
        res
          .status(500)
          .json({ success: false, message: "Failed to update UID" });
      }
    } finally {
      // Release the connection back to the pool
      connection.release();
    }
  } catch (error) {
    console.error("Error updating UID:", error);
    res.status(500).json({ success: false, message: "Internal Server Error" });
  }
});

async function isValidTicketId(ticketid) {
  try {
    const connection = await pool.getConnection();
    await connection.beginTransaction();

    try {
      // Execute the first query to select data
      const [selectRows, selectFields] = await connection.execute(
        `SELECT * FROM namma_ticket WHERE Ticket_Id="${ticketid}" AND Validity=1`
      );

      // Check if the ticket is valid
      if (selectRows.length === 1) {
        // Execute the second query to update validity
        await connection.execute(
          `UPDATE namma_ticket SET Validity = 0 WHERE Ticket_Id="${ticketid}" AND Validity=1`
        );

        // Commit the transaction
        await connection.commit();
        return true;
      } else {
        // Rollback the transaction if the ticket is not valid
        await connection.rollback();
        return false;
      }
    } catch (error) {
      // Rollback the transaction on any error
      await connection.rollback();
      throw error;
    } finally {
      // Release the connection back to the pool
      connection.release();
    }
  } catch (error) {
    console.error("Error fetching data from MySQL:", error);
    throw error;
  }
}

// Start the server
app.listen(port, () => {
  console.log(`Server listening at http://localhost:${port}/api/buses`);
});

// Signup endpoint
// Signup endpoint
app.post("/signup", async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) {
    return res
      .status(400)
      .json({ message: "Username and password are required." });
  }

  try {
    const connection = await pool.getConnection();
    console.log("first try");
    try {
      // Check if username already exists
      const [existingUsers] = await connection.execute(
        "SELECT * FROM users WHERE username = ?",
        [username]
      );
      console.log("second try");
      if (existingUsers.length > 0) {
        return res.status(409).json({ message: "Username already exists." });
      }

      // Hash the password
      const hashedPassword = await bcrypt.hash(password, saltRounds);

      // Create new user
      await connection.execute(
        "INSERT INTO users (username, password) VALUES (?, ?)",
        [username, hashedPassword] // Corrected parameters
      );

      return res.status(201).json({ message: "Signup successful." });
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error("Error during signup:", error);
    return res.status(500).json({ message: "Internal Server Error" });
  }
});

// Login endpoint
// Login endpoint
app.post("/login", async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) {
    return res
      .status(400)
      .json({ message: "Username and password are required." });
  }

  try {
    const connection = await pool.getConnection();
    try {
      // Fetch user by username
      const [users] = await connection.execute(
        "SELECT * FROM users WHERE username = ?",
        [username]
      );

      if (users.length === 0) {
        return res
          .status(401)
          .json({ message: "Invalid username or password." });
      }

      const user = users[0];

      // Compare hashed passwords
      const passwordMatch = await bcrypt.compare(password, user.password);

      if (!passwordMatch) {
        return res
          .status(401)
          .json({ message: "Invalid username or password." });
      }

      return res.status(200).json({ message: "Login successful." });
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error("Error during login:", error);
    return res.status(500).json({ message: "Internal Server Error" });
  }
});

//bus pass endpoint
app.post("/api/storePassEntry", async (req, res) => {
  console.log("Hello post");
  console.log("req:", req.body);
  const name = req.body.name;
  const age = req.body.age;
  const address = req.body.address;
  const passid = req.body.passid;
  const time = new Date();
  time.setDate(time.getDate() + 30);
  const expirationDate = time.toISOString().split("T")[0];

  try {
    const connection = await pool.getConnection();

    try {
      // Execute the query to update the database with the new pass entry
      const [result] = await connection.execute(
        "INSERT INTO bus_pass (PassId, Username, Age, Address, Validity, Status) VALUES (?, ?, ?, ?, ?,?)",
        [passid, name, age, address, expirationDate, 1]
      );

      // Check if the query was successful
      if (result.affectedRows === 1) {
        res
          .status(200)
          .json({ success: true, message: "Pass entry added successfully" });
      } else {
        res
          .status(500)
          .json({ success: false, message: "Failed to add pass entry" });
      }
    } finally {
      // Release the connection back to the pool
      connection.release();
    }
  } catch (error) {
    console.error("Error adding pass entry:", error);
    res.status(500).json({ success: false, message: "Internal Server Error" });
  }
});
