import { render, screen } from '@testing-library/react';
import BudgetRemediator from './BudgetRemediator';

describe('BudgetRemediator', () => {
    it('renders Budget Remediator text', () => {
        render(<BudgetRemediator />);
        const div = screen.getByText(/Budget Remediator/i);
        expect(div).toBeInTheDocument();
        expect(div.tagName).toBe('DIV');
    });
});
