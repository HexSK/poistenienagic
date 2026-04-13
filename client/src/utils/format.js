export function formatDate(value) {
    if (!value) return '-';
    const date = new Date(value);
    if (Number.isNaN(date.getTime())) return String(value);
    return date.toLocaleDateString('sk-SK');
}

export function formatMoneyEur(value) {
    if (value === null || value === undefined || value === '') return '-';
    const numberValue = typeof value === 'number' ? value : Number(value);
    if (Number.isNaN(numberValue)) return String(value);
    return new Intl.NumberFormat('sk-SK', { style: 'currency', currency: 'EUR' }).format(numberValue);
}

