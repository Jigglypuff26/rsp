import { StrictMode, type ReactNode } from 'react';

interface AppProviderProps {
  children: ReactNode;
}

export const AppProvider = ({ children }: AppProviderProps) => <StrictMode>{children}</StrictMode>;
