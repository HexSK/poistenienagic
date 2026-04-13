import { BrowserRouter, Routes, Route } from 'react-router-dom';
import './App.css';
import Home from './pages/Home.jsx';
import Register from './pages/auth/Register.jsx';
import Login from './pages/auth/Login.jsx';
import MojUcet from './pages/user/MojUcet.jsx';
import MojUcetPrehlad from './pages/user/MojUcetPrehlad.jsx';
import KlientZmluvy from './pages/user/KlientZmluvy.jsx';
import KlientZmluva from './pages/user/KlientZmluva.jsx';
import KlientZmluvaFaktury from './pages/user/KlientZmluvaFaktury.jsx';
import KlientZmluvaFaktura from './pages/user/KlientZmluvaFaktura.jsx';
import ZaplatFakturu from './pages/user/ZaplatFakturu.jsx';
import PoistneUdalosti from './pages/user/PoistneUdalosti.jsx';
import NovaZiadostZmluva from './pages/user/NovaZiadostZmluva.jsx';
import AdminPrehlad from './pages/admin/AdminPrehlad.jsx';
import AdminUzivatelPrehlad from './pages/admin/AdminUzivatelPrehlad.jsx';
import AdminZiadosti from './pages/admin/AdminZiadosti.jsx';
import AdminZiadost from './pages/admin/AdminZiadost.jsx';
import AdminPoistneUdalosti from './pages/admin/AdminPoistneUdalosti.jsx';
import NotFound from './pages/NotFound.jsx';
import AppNav from './components/AppNav.jsx';
import RequireAuth from './components/RequireAuth.jsx';
import RequireAdmin from './components/RequireAdmin.jsx';

function App() {
  return (
    <BrowserRouter>
      <AppNav />
      <Routes>
        <Route path="/" element={<Home />}></Route>
        <Route path="/register" element={<Register />}></Route>
        <Route path="/login" element={<Login />}></Route>

        <Route
          path="/moj-ucet"
          element={
            <RequireAuth>
              <MojUcet />
            </RequireAuth>
          }
        ></Route>
        <Route
          path="/moj-ucet/prehlad"
          element={
            <RequireAuth>
              <MojUcetPrehlad />
            </RequireAuth>
          }
        ></Route>
        <Route
          path="/moj-ucet/zmluvy"
          element={
            <RequireAuth>
              <KlientZmluvy />
            </RequireAuth>
          }
        ></Route>
        <Route
          path="/moj-ucet/zmluva/:id_zmluva"
          element={
            <RequireAuth>
              <KlientZmluva />
            </RequireAuth>
          }
        ></Route>
        <Route
          path="/moj-ucet/zmluva/:id_zmluva/faktury"
          element={
            <RequireAuth>
              <KlientZmluvaFaktury />
            </RequireAuth>
          }
        ></Route>
        <Route
          path="/moj-ucet/zmluva/:id_zmluva/faktura/:id_faktura"
          element={
            <RequireAuth>
              <KlientZmluvaFaktura />
            </RequireAuth>
          }
        ></Route>
        <Route
          path="/moj-ucet/zmluva/:id_zmluva/faktura/:id_faktura/zaplat"
          element={
            <RequireAuth>
              <ZaplatFakturu />
            </RequireAuth>
          }
        ></Route>
        <Route
          path="/moj-ucet/nova-ziadost"
          element={
            <RequireAuth>
              <NovaZiadostZmluva />
            </RequireAuth>
          }
        ></Route>
        <Route
          path="/moj-ucet/poistne-udalosti"
          element={
            <RequireAuth>
              <PoistneUdalosti />
            </RequireAuth>
          }
        ></Route>

        <Route
          path="/moj-ucet/admin/prehlad"
          element={
            <RequireAdmin>
              <AdminPrehlad />
            </RequireAdmin>
          }
        ></Route>
        <Route
          path="/moj-ucet/admin/prehlad/uzivatel/:id_uzivatel"
          element={
            <RequireAdmin>
              <AdminUzivatelPrehlad />
            </RequireAdmin>
          }
        ></Route>
        <Route
          path="/moj-ucet/admin/ziadosti"
          element={
            <RequireAdmin>
              <AdminZiadosti />
            </RequireAdmin>
          }
        ></Route>
        <Route
          path="/moj-ucet/admin/ziadost/:id_ziadost"
          element={
            <RequireAdmin>
              <AdminZiadost />
            </RequireAdmin>
          }
        ></Route>
        <Route
          path="/moj-ucet/admin/poistne-udalosti"
          element={
            <RequireAdmin>
              <AdminPoistneUdalosti />
            </RequireAdmin>
          }
        ></Route>

        <Route path="*" element={<NotFound />}></Route>
      </Routes>
    </BrowserRouter>
  )
}

export default App;
