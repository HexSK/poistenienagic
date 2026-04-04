import { Button, Form, Row, Col, Alert } from 'react-bootstrap';
import { useState } from 'react';
import axios from 'axios';


const API_ENDPOINT = import.meta.env.VITE_POISTENIENAGIC_API;

function Register() {

    const [typUzivatela, setTypUzivatela] = useState('k');
    const [meno, setMeno] = useState('');
    const [priezvisko, setPriezvisko] = useState('');
    const [datumNarodenia, setDatumNarodenia] = useState('');
    const [rodCislo, setRodCislo] = useState('');
    const [telCislo, setTelCislo] = useState('');
    const [ulicaC, setUlicaC] = useState('');
    const [mesto, setMesto] = useState('');
    const [PSC, setPSC] = useState('');
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');
    const [nazovFirma, setNazovFirma] = useState(null);
    const [ICO, setICO] = useState(null);
    const [DIC, setDIC] = useState(null);
    const [success, setSuccess] = useState(false);
    const [error, setError] = useState(null);

    const handlePassword = (heslo) => {
        if (heslo.length <= 8) {
            setError('Heslo musí byť dlhšie ako 8 znakov');
            return;
        }
        setPassword(heslo);
        setError(null); // Clear error if password is valid
    };

    const handleConfirmPassword = (confirmHeslo) => {
        setConfirmPassword(confirmHeslo);
        if (password && confirmHeslo !== password) {
            setError('Heslá sa nezhodujú.');
        } else {
            setError(null);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();


        if (!meno || !priezvisko || !datumNarodenia || !rodCislo || !telCislo || !ulicaC || !mesto || !PSC || !email || !password || !confirmPassword) {
            setError('Prosím vyplňte všetky polia!');
            return;
        }

        if (password !== confirmPassword) {
            setError('Heslá sa nezhodujú.');
            return;
        }

        if (nazovFirma && !(ICO || DIC)) {
            setError('Prosím vyplňte všetky polia!');
            return;
        }

        let userType = 'k';
        if (nazovFirma && ICO && DIC) {
            userType = 'kf';
        }

        try {
            const response = await axios.post(API_ENDPOINT+'/api/register',
                {
                    typ_uzivatela: userType,
                    meno: meno,
                    priezvisko: priezvisko,
                    datum_narodenia: datumNarodenia,
                    rod_cislo: rodCislo,
                    tel_c: telCislo,
                    ulica_c: ulicaC,
                    mesto: mesto,
                    PSC: PSC,
                    email: email,
                    password: password,
                    nazo_firma: nazovFirma || null,
                    ICO: ICO || null,
                    DIC: DIC || null
                }
            );
            console.log("Registracia uspesna", response.data);
            setSuccess(true);
            setError(null);
        } catch (error){
            console.error("Chyba pri registracii", error);
            setError("Pri registracii sa vyskytla chyba.");
        }        
    };

    return (
        <>
            <Form onSubmit={handleSubmit}>
                <Row>
                    <Col md={6}>
                        <Form.Group className="mb-3" controlId="registerMeno">
                            <Form.Label>Meno</Form.Label>
                            <Form.Control type="text" placeholder="Vložte meno" required onChange={(e) => setMeno(e.target.value)} />
                        </Form.Group>
                    </Col>

                    <Col md={6}>
                        <Form.Group className="mb-3" controlId="registerPriezvisko">
                            <Form.Label>Priezvisko</Form.Label>
                            <Form.Control type="text" placeholder="Vložte priezvisko" required onChange={(e) => setPriezvisko(e.target.value)} />
                        </Form.Group>
                    </Col>
                </Row>
                <Row>
                    <Form.Group className="mb-3" controlId="registerDatumNarodenia">
                        <Form.Label>Dátum narodenia</Form.Label>
                        <Form.Control type="date" required onChange={(e) => setDatumNarodenia(e.target.value)} />
                    </Form.Group>
                </Row>
                <Row>
                    <Form.Group className="mb-3" controlId="registerRodneCislo">
                        <Form.Label>Rodné číslo</Form.Label>
                        <Form.Control type="text" placeholder="Vložte rodné číslo" required onChange={(e) => setRodCislo(e.target.value)} />
                    </Form.Group>
                </Row>
                <Row>
                    <Form.Group className="mb-3" controlId="registerTelCislo">
                        <Form.Label>Telefónne číslo</Form.Label>
                        <Form.Control type="text" placeholder="Vložte telefónne číslo" required onChange={(e) => setTelCislo(e.target.value)} />
                    </Form.Group>
                </Row>
                <Row>
                    <Form.Group className="mb-3" controlId="registerAdresa">
                        <Form.Label>Adresa</Form.Label>
                        <Form.Control type="text" placeholder="Vložte adresu" required onChange={(e) => setUlicaC(e.target.value)} />
                    </Form.Group>
                </Row>

                <Row>
                    <Col md={6}>
                        <Form.Group className="mb-3" controlId="registerMesto">
                            <Form.Label>Mesto</Form.Label>
                            <Form.Control type="text" placeholder="Vložte mesto" required onChange={(e) => setMesto(e.target.value)} />
                        </Form.Group>
                    </Col>
                    <Col md={6}>
                        <Form.Group className="mb-3" controlId="registerPsc">
                            <Form.Label>PSČ</Form.Label>
                            <Form.Control type="text" placeholder="Vložte PSČ" required onChange={(e) => setPSC(e.target.value)} />
                        </Form.Group>
                    </Col>
                </Row>
                <Row>
                    <Form.Group className="mb-3" controlId="registerEmail">
                        <Form.Label>E-Mail</Form.Label>
                        <Form.Control type="email" placeholder="Vložte E-Mail" required onChange={(e) => setEmail(e.target.value)} />
                    </Form.Group>
                </Row>
                <Row>
                    <Col md={6}>
                        <Form.Group className="mb-3" controlId="registerPassword">
                            <Form.Label>Heslo</Form.Label>
                            <Form.Control type="password" placeholder="Vložte heslo" required onChange={(e) => handlePassword(e.target.value)} />
                        </Form.Group>
                    </Col>
                    <Col md={6}>
                        <Form.Group className="mb-3" controlId="registerConfirmPassword">
                            <Form.Label>Potvrdiť heslo</Form.Label>
                            <Form.Control type="password" placeholder="Potvrďte heslo" required onChange={(e) => handleConfirmPassword(e.target.value)} />
                        </Form.Group>
                    </Col>
                </Row>
                <Row>
                    <Form.Group className="mb-3" controlId="registerFirm">
                        <Form.Label>Názov firmy</Form.Label>
                        <Form.Control type="text" placeholder="Vložte názov firmy" onChange={(e) => setNazovFirma(e.target.value)}/>
                    </Form.Group>
                </Row>
                <Row>
                    <Col md={6}>
                        <Form.Group className="mb-3" controlId="registerIco">
                            <Form.Label>IČO</Form.Label>
                            <Form.Control type="text" placeholder="Vložte IČO" onChange={(e) => setICO(e.target.value)}/>
                        </Form.Group>
                    </Col>
                    <Col md={6}>
                        <Form.Group className="mb-3" controlId="registerIco">
                            <Form.Label>DIČ</Form.Label>
                            <Form.Control type="text" placeholder="Vložte DIČ" onChange={(e) => setDIC(e.target.value)}/>
                        </Form.Group>
                    </Col>
                </Row>
                <Button type="submit" className='w-100'>Registrovať</Button>
            </Form>
            {success && <Alert variant="success">Form submitted successfully!</Alert>}
            {error && <Alert variant="danger">{error}</Alert>}
        </>
    );
}

export default Register;