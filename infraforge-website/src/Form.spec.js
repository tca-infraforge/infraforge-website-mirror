import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import Form from './Form';

describe('Form', () => {
    it('renders the form and heading', () => {
        render(<Form />);
        expect(screen.getByRole('form')).toBeInTheDocument();
        expect(screen.getByRole('heading', { level: 2 })).toHaveTextContent('Booking Form');
    });
});
