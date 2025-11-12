// app/debug/page.tsx
export default function DebugPage() {
  return (
    <div>
      <h2>Environment Variables:</h2>
      <p>API URL: {process.env.NEXT_PUBLIC_API_URL || 'Not set'}</p>
      <p>Database: {process.env.DATABASE_URL ? 'Set' : 'Not set'}</p>
    </div>
  );
}