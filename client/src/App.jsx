import { useState } from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import './App.css';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Home />}></Route>
        <Route path="/register" element={<Register />}></Route>
        <Route path="/login" element={<Login />}></Route>
        <Route path="/logout" element={<Logout />}></Route>
        <Route path="/moj-ucet" element={<MojUcet />}></Route>
        <Route path="/moj-ucet/prehlad" element={<MojUcetPrehlad />}></Route>
        <Route path="/moj-ucet/zmluvy" element={<KlientZmluvy />}></Route>
        <Route path="/moj-ucet/zmluva/:id_zmluva" element={<KlientZmluva/>}></Route>
        <Route path="/moj-ucet/zmluva/:id_zmluva/faktury" element={<KlientZmluvaFaktury/>}></Route>
        <Route path="/moj-ucet/zmluva/:id_zmluva/faktura/:id_faktura" element={<KlientZmluvaFaktura/>}></Route>
        <Route path="/moj-ucet/zmluva/:id_zmluva/faktura/:id_faktura/zaplat" element={<ZaplatFakturu/>}></Route>
      </Routes>
    </BrowserRouter>
  )
}

export default App
