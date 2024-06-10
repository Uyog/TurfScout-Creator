import React, { useState } from 'react';
import MyButton from '../components/Button';
import Alert from '../components/Alert';
import { IonInput, IonItem, IonIcon } from '@ionic/react';
import { mailOutline } from 'ionicons/icons';
import { useHistory } from 'react-router-dom';
import './Auth.css';
import Lottie from 'react-lottie';
import loadingAnimation from '../components/Loading2.json';

const roundedTextField = {
  borderRadius: '10px',
};

const textColorStyle = {
  color: '#97FB57',
};

const boldTextStyle = {
  fontWeight: 'bold',
};

const iconColorStyle = {
  color: '#97FB57',
};

const cardStyle = {
  maxWidth: '400px',
  margin: 'auto',
  padding: '20px',
  borderRadius: '10px',
  boxShadow: '0 4px 8px rgba(0, 0, 0, 0.1)',
  backgroundColor: '#1a1a1a',
};

const pageStyle = {
  backgroundColor: '#000', // Set background color to black
  height: '100vh',
  display: 'flex',
  justifyContent: 'center',
  alignItems: 'center',
};

const ForgotPassword: React.FC = () => {
  const [email, setEmail] = useState('');
  const [emailError, setEmailError] = useState('');
  const [error, setError] = useState('');
  const [showAlert, setShowAlert] = useState(false);
  const [loading, setLoading] = useState(false);
  const [alertType, setAlertType] = useState<'success' | 'error'>('error');

  const history = useHistory();

  const handleBackClick = () => {
    history.goBack();
  };

  const handleSendResetLink = async () => {
    try {
      setLoading(true);
      const response = await fetch('http://127.0.0.1:8000/api/forgot-password', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email }),
      });

      if (response.ok) {
        setAlertType('success');
        setShowAlert(true);
      } else {
        if (response.status === 404) {
          setError('Email not found. Please check the email address and try again.');
        } else if (response.status === 422) {
          setError('Invalid email format. Please enter a valid email address.');
        } else {
          setError('An unexpected error occurred. Please try again later.');
        }
        setAlertType('error');
        setShowAlert(true);
      }
    } catch (error) {
      console.error('Forgot password error:', error);
      setError('An unexpected error occurred. Please try again later.');
      setAlertType('error');
      setShowAlert(true);
    } finally {
      setLoading(false);
    }
  };

  const validateEmail = (value: string) => {
    if (!value) {
      setEmailError('Email is required');
    } else if (!/\S+@\S+\.\S+/.test(value)) {
      setEmailError('Invalid email address');
    } else {
      setEmailError('');
    }
  };

  const handleSubmit = () => {
    validateEmail(email);

    if (!emailError) {
      handleSendResetLink();
    } else {
      setShowAlert(true);
    }
  };

  return (
    <div className="auth-container" style={pageStyle}>
      <div style={cardStyle}>
        {loading && (
          <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
            <Lottie options={{ animationData: loadingAnimation }} width={100} height={100} />
          </div>
        )}
        <h1 style={{ ...textColorStyle, ...boldTextStyle, textAlign: 'center', marginBottom: '20px' }}>Forgot Password</h1>
        <IonItem style={{ ...roundedTextField, borderColor: emailError ? 'red' : '', marginBottom: '20px' }}>
          <IonIcon icon={mailOutline} slot="start" style={iconColorStyle} />
          <IonInput
            placeholder="Email"
            type="email"
            value={email}
            onIonChange={(e) => setEmail(e.detail.value!)}
            style={textColorStyle}
          />
        </IonItem>
        <MyButton text="Send" onClick={handleSubmit} />
        <div style={{ marginBottom: '10px' }}></div>
        <MyButton text="Back" onClick={handleBackClick} />

        <Alert
          isOpen={showAlert}
          type={alertType}
          content={alertType === 'success' ? 'Reset link sent successfully!' : error}
          onClose={() => setShowAlert(false)}
        />
      </div>
    </div>
  );
};

export default ForgotPassword;
