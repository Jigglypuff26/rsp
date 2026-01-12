import React from 'react';
import logo from '../../shared/assets/logo.svg';
import './styles.css';

export const MainPage = () => (
  <div className="main-page">
    <header className="main-page__header">
      <img src={logo} className="main-page__logo" alt="logo" />
      <p>правки +++++ docker compose dev 2026</p>
    </header>
  </div>
);
