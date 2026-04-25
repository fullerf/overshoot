import { useEffect, useState } from "react";

export function Home() {
  const [message, setMessage] = useState<string>("loading...");

  useEffect(() => {
    fetch("/api/hello")
      .then((r) => r.json())
      .then((d) => setMessage(d.message))
      .catch((e) => setMessage(`error: ${e.message}`));
  }, []);

  return (
    <div className="min-h-screen flex items-center justify-center bg-background text-foreground">
      <div className="text-center space-y-4">
        <h1 className="text-4xl font-semibold">overshoot</h1>
        <p className="text-muted-foreground">{message}</p>
      </div>
    </div>
  );
}
