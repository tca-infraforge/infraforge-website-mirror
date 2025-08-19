import { render, screen } from '@testing-library/react';
import App from './App';

test('renders main heading and call-to-action', () => {
  render(<App />);
  expect(screen.getByRole('heading', { level: 1 })).toHaveTextContent('infraForge Website Platform');
  expect(screen.getByText(/Book a service with us!/i)).toBeInTheDocument();
});
