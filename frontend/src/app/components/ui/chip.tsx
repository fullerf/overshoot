export function Chip({
  label,
  variant = "default",
}: {
  label: string;
  variant?: "default" | "success" | "warning" | "error";
}) {
  const styles = {
    default: "bg-muted text-foreground border-border",
    success: "bg-chart-2/10 text-chart-2 border-chart-2/20",
    warning: "bg-amber-500/10 text-amber-600 border-amber-500/20",
    error: "bg-destructive/10 text-destructive border-destructive/20",
  };

  return (
    <span
      className={`inline-flex items-center gap-1.5 px-3 py-1.5 rounded border ${styles[variant]}`}
      style={{ fontSize: "var(--text-label)", fontWeight: "var(--font-weight-medium)" }}
    >
      {label}
    </span>
  );
}
