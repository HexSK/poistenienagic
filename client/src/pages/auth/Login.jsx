import { Alert, Button, Form, Row } from 'react-bootstrap';
import { useState } from 'react';
import { useAuth } from './AuthContext.jsx';
import { useNavigate } from 'react-router-dom';

function Login() {
    const { login } = useAuth();
    const navigate = useNavigate();
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState(null);

    const handleLogin = async (e) => {
        e.preventDefault();
        setError(null);
        try {
            await login(email, password);
            navigate('/moj-ucet');
        } catch (err) {
            const serverError = err?.response?.data?.error;
            setError(serverError || 'Neplatné údaje!');
        }
    };

    return (
        <>
            <h1>Prihlásenie</h1>
            <Form onSubmit={handleLogin}>
                <Row>
                    <Form.Group className="mb-3" controlId="loginEmail">
                        <Form.Label>E-mail</Form.Label>
                        <Form.Control
                            type="email"
                            placeholder="Vložte e-mail"
                            required
                            onChange={(e) => setEmail(e.target.value)}
                        />
                    </Form.Group>
                </Row>
                <Row>
                    <Form.Group className="mb-3" controlId="loginPassword">
                        <Form.Label>Heslo</Form.Label>
                        <Form.Control
                            type="password"
                            placeholder="Vložte heslo"
                            required
                            onChange={(e) => setPassword(e.target.value)}
                        />
                    </Form.Group>
                </Row>
                <Button type="submit" className="w-100">
                    Prihlásiť
                </Button>
            </Form>
            {error && (
                <Alert className="mt-3" variant="danger">
                    {error}
                </Alert>
            )}
        </>
    );
}

export default Login;

