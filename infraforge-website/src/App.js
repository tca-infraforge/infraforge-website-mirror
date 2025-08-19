import React, { useState } from 'react';
import sanitizeHtml from 'sanitize-html';
import { Form, Button, Alert, Container, Row, Col } from 'react-bootstrap';
import 'bootstrap/dist/css/bootstrap.min.css';
import './App.css';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:3000/submit';
const API_SECRET = process.env.REACT_APP_API_SECRET_KEY || '';

function App() {
  const [formData, setFormData] = useState({ name: '', email: '', service: '' });
  const [submitted, setSubmitted] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleChange = (e) => {
    const { name, value } = e.target;
    const sanitizedValue = sanitizeHtml(value, { allowedTags: [], allowedAttributes: {} });
    setFormData({ ...formData, [name]: sanitizedValue });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      if (!formData.name || !formData.email || !formData.service) {
        throw new Error('All fields are required');
      }

      const response = await fetch(API_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': API_SECRET,
        },
        body: JSON.stringify(formData),
      });

      const data = await response.json();
      if (!response.ok) throw new Error(data.message || 'Submission failed');

      setSubmitted(true);
    } catch (err) {
      setError(err.message || 'Submission failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Container className="App">
      <Row className="justify-content-center">
        <Col md={6}>
          <h1 className="text-center mt-5">infraForge Website Platform</h1>
          <p className="text-center">Book a service with us!</p>
          {submitted ? (
            <Alert variant="success">
              <h2>Thank You, {formData.name}!</h2>
              <p>Your booking for {formData.service} has been received.</p>
            </Alert>
          ) : (
            <Form onSubmit={handleSubmit}>
              {error && <Alert variant="danger">{error}</Alert>}
              <Form.Group controlId="formName" className="mb-3">
                <Form.Label>Name</Form.Label>
                <Form.Control
                  type="text"
                  name="name"
                  value={formData.name}
                  onChange={handleChange}
                  required
                  placeholder="Enter your name"
                />
              </Form.Group>
              <Form.Group controlId="formEmail" className="mb-3">
                <Form.Label>Email</Form.Label>
                <Form.Control
                  type="email"
                  name="email"
                  value={formData.email}
                  onChange={handleChange}
                  required
                  placeholder="Enter your email"
                />
              </Form.Group>
              <Form.Group controlId="formService" className="mb-3">
                <Form.Label>Service</Form.Label>
                <Form.Select
                  name="service"
                  value={formData.service}
                  onChange={handleChange}
                  required
                >
                  <option value="">Select a service</option>
                  <option value="Consultation">Consultation</option>
                  <option value="Support">Support</option>
                  <option value="Training">Training</option>
                </Form.Select>
                </Form.Group>

              <Button variant="primary" type="submit" disabled={loading} className="w-100">
                {loading ? 'Submitting...' : 'Book Now'}
              </Button>
            </Form>
          )}
        </Col>
      </Row>
    </Container>
  );
}

export default App;
