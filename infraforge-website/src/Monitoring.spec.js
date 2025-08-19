import { render, screen } from '@testing-library/react';
import Monitoring from './Monitoring';

describe('Monitoring', () => {
    it('renders Monitoring Dashboard text', () => {
        render(<Monitoring />);
        const div = screen.getByText(/Monitoring Dashboard/i);
        expect(div).toBeInTheDocument();
        expect(div.tagName).toBe('DIV');
    });
});
