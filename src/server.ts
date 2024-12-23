import express from 'express';
import router from "./routes/userRoutes";



const app = express();
app.use(express.json());

app.use('/api/v1', router);


app.listen((process.env.PORT || 4000), async () => {
  console.log('listening on http://localhost:4000');
});
