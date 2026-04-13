import { Button } from 'react-bootstrap';
import { useNavigate } from 'react-router-dom';

function NotFound() {
  const navigate = useNavigate();
  return (
    <div>
      <h1>Stránka sa nenašla</h1>
      <p>Skontrolujte URL adresu alebo sa vráťte na úvod.</p>
      <Button onClick={() => navigate('/')}>Späť na úvod</Button>
    </div>
  );
}

export default NotFound;

