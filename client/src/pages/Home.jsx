import { Button, Card, Stack } from 'react-bootstrap';
import { useNavigate } from 'react-router-dom';
import { useAuth } from './auth/AuthContext.jsx';

function Home() {
    const navigate = useNavigate();
    const { user, loading } = useAuth();

    return (
        <Card>
            <Card.Body>
                <Card.Title>Poistenie Nagic</Card.Title>
                <Card.Text>
                    Prihláste sa do svojho účtu, pozrite si zmluvy, faktúry a poistné udalosti.
                </Card.Text>
                <Stack gap={2} className="col-md-6 mx-auto">
                    {!loading && user && <Button onClick={() => navigate('/moj-ucet')}>Prejsť do účtu</Button>}
                    {!loading && !user && (
                        <>
                            <Button onClick={() => navigate('/login')}>Prihlásiť sa</Button>
                            <Button variant="outline-primary" onClick={() => navigate('/register')}>
                                Registrovať sa
                            </Button>
                        </>
                    )}
                </Stack>
            </Card.Body>
        </Card>
    );
}

export default Home;

