import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { 
  createEmergency,
  acceptEmergency,
  rejectEmergency
} from "./controllers/emergencyController.js";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

app.post("/emergency", createEmergency);
app.post("/emergency/:id/accept", acceptEmergency);
app.post("/emergency/:id/reject", rejectEmergency);

app.listen(5000, () => {
  console.log("🚀 Server running at http://localhost:5000");
});


