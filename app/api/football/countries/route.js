import { Pool } from 'pg';

// Hem Neon.tech hem local DB destegi
const getPool = () => {
  if (process.env.DATABASE_URL) {
    // Neon.tech
    return new Pool({
      connectionString: process.env.DATABASE_URL,
      ssl: { rejectUnauthorized: false }
    });
  } else {
    // Local Docker DB
    return new Pool({
      user: process.env.DB_USER || 'postgres',
      host: process.env.DB_HOST || 'localhost',
      database: process.env.DB_NAME || 'football',
      password: process.env.DB_PASSWORD || 'mysecretpassword',
      port: parseInt(process.env.DB_PORT) || 5432,
    });
  }
};

const pool = getPool();

export async function GET() {
  console.log('🔗 Using database:', process.env.DATABASE_URL ? 'Neon.tech' : 'Local');
  
  try {
    const client = await pool.connect();
    const result = await client.query('SELECT NOW() as current_time');
    client.release();
    
    return Response.json({
      success: true,
      message: 'Database bağlantısı başarılı!',
      database: process.env.DATABASE_URL ? 'Neon.tech' : 'Local PostgreSQL',
      current_time: result.rows[0].current_time
    });
  } catch (error) {
    return Response.json({
      success: false,
      error: error.message,
      database: process.env.DATABASE_URL ? 'Neon.tech' : 'Local PostgreSQL'
    }, { status: 500 });
  }
}