import { BrowserRouter, Routes, Route } from 'react-router-dom';
import './App.css';
import Home from './pages/Home.jsx';
import Register from './pages/auth/Register.jsx';
// import Login from './pages/auth/Login.jsx';
// import Logout from './pages/auth/Logout.jsx';
// import MojUcet from './pages/user/MojUcet.jsx';
// import MojUcetPrehlad from './pages/user/MojUcetPrehlad.jsx';
// import KlientZmluvy from './pages/user/KlientZmluvy.jsx';
// import KlientZmluva from './pages/user/KlientZmluva.jsx';
// import KlientZmluvaFaktury from './pages/user/KlientZmluvaFaktury.jsx';
// import KlientZmluvaFaktura from './pages/user/KlientZmluvaFaktura.jsx';
// import ZaplatFakturu from './pages/user/ZaplatFakturu.jsx';
// import PoistneUdalosti from './pages/user/PoistneUdalosti.jsx';
// import AdminPrehlad from './pages/admin/AdminPrehlad.jsx';
// import AdminUzivatelPrehlad from './pages/admin/AdminUzivatelPrehlad.jsx';
// import AdminZiadosti from './pages/admin/AdminZiadosti.jsx';
// import AdminZiadost from './pages/admin/AdminZiadost.jsx';
// import AdminPoistneUdalosti from './pages/admin/AdminPoistneUdalosti.jsx';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Home />}></Route>
        <Route path="/register" element={<Register />}></Route>
        {/* <Route path="/login" element={<Login />}></Route>
        <Route path="/logout" element={<Logout />}></Route>
        <Route path="/moj-ucet" element={<MojUcet />}></Route>
        <Route path="/moj-ucet/prehlad" element={<MojUcetPrehlad />}></Route>
        <Route path="/moj-ucet/zmluvy" element={<KlientZmluvy />}></Route>
        <Route path="/moj-ucet/zmluva/:id_zmluva" element={<KlientZmluva/>}></Route>
        <Route path="/moj-ucet/zmluva/:id_zmluva/faktury" element={<KlientZmluvaFaktury/>}></Route>
        <Route path="/moj-ucet/zmluva/:id_zmluva/faktura/:id_faktura" element={<KlientZmluvaFaktura/>}></Route>
        <Route path="/moj-ucet/zmluva/:id_zmluva/faktura/:id_faktura/zaplat" element={<ZaplatFakturu/>}></Route>
        <Route path="/moj-ucet/poistne-udalosti" element={<PoistneUdalosti />}></Route>
        <Route path="/moj-ucet/admin/prehlad" element={<AdminPrehlad />}></Route>
        <Route path="/moj-ucet/admin/prehlad/uzivatel/:id_uzivatel" element={<AdminUzivatelPrehlad />}></Route>
        <Route path="/moj-ucet/admin/ziadosti" element={<AdminZiadosti />}></Route>
        <Route path="/moj-ucet/admin/ziadost/:id_ziadosti" element={<AdminZiadost />}></Route>
        <Route path="/moj-ucet/admin/poistne-udalosti" element={<AdminPoistneUdalosti />}></Route> */}
      </Routes>
    </BrowserRouter>
  )
}

export default App;