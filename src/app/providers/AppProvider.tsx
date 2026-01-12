import React from 'react';

interface AppProviderProps {
  children: React.ReactNode;
}

export const AppProvider = ({ children }: AppProviderProps) => (
  <React.StrictMode>{children}</React.StrictMode>
);
