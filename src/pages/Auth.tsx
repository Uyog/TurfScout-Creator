import React, { useState } from 'react';
import MyButton from '../components/Button';
import Alert from '../components/Alert';
import { IonInput, IonItem, IonIcon } from '@ionic/react';
import { eyeOffOutline, eyeOutline, lockClosedOutline, mailOutline, personOutline } from 'ionicons/icons';
import { useHistory } from 'react-router-dom';
import './Auth.css';

interface LoginProps {
  onSignUpClick: () => void;
}

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

const Login: React.FC<LoginProps> = ({ onSignUpClick }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [emailError, setEmailError] = useState('');
  const [passwordError, setPasswordError] = useState('');
  const [error, setError] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [showAlert, setShowAlert] = useState(false);
  const [showSuccessAlert, setShowSuccessAlert] = useState(false);

  const history = useHistory();

  const handleLogin = async () => {
    try {
      const response = await fetch('http://127.0.0.1:8000/api/login', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email, password }),
      });

      if (response.ok) {
        const data = await response.json();
        localStorage.setItem('token', data.token);
        setShowSuccessAlert(true);
        history.push('/home');
      } else {
        if (response.status === 401) {
          setError('Invalid email or password');
        } else {
          setError('An unexpected error occurred');
        }
        setShowAlert(true);
      }
    } catch (error) {
      console.error('Login error:', error);
      setError('An unexpected error occurred');
      setShowAlert(true);
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

  const validatePassword = (value: string) => {
    if (!value) {
      setPasswordError('Password is required');
    } else {
      setPasswordError('');
    }
  };

  const handleSubmit = () => {
    validateEmail(email);
    validatePassword(password);

    if (!emailError && !passwordError) {
      handleLogin();
    } else {
      setShowAlert(true);
    }

    try {
      // API request code
    } catch (error) {
      console.error('Error:', error);
      setError('An unexpected error occurred');
      setShowAlert(true);
    }
  };

  return (
    <div className="container" style={textColorStyle}>
      <h1 style={{ ...textColorStyle, ...boldTextStyle, textAlign: 'center', marginBottom: 50 }}>Login</h1>
      <IonItem style={{ ...roundedTextField, borderColor: emailError ? 'red' : '' }}>
        <IonIcon icon={mailOutline} slot="start" style={iconColorStyle} />
        <IonInput
          placeholder="Email"
          type="email"
          value={email}
          onIonChange={(e) => setEmail(e.detail.value!)}
          style={textColorStyle}
        />
      </IonItem>
      <div style={{ marginBottom: '30px' }} />
      <IonItem style={roundedTextField}>
        <IonIcon icon={lockClosedOutline} slot="start" style={iconColorStyle} />
        <IonInput
          placeholder="Password"
          type={showPassword ? 'text' : 'password'}
          value={password}
          onIonChange={(e) => setPassword(e.detail.value!)}
          style={textColorStyle}
        />
        <IonIcon
          icon={showPassword ? eyeOffOutline : eyeOutline}
          slot="end"
          onClick={() => setShowPassword(!showPassword)}
          style={iconColorStyle}
        />
      </IonItem>
      <div style={{ marginBottom: '16px' }} />

      <MyButton text="Login" onClick={handleSubmit} />
      <p style={{ textAlign: 'center' }}>
        Don't have an account?{' '}
        <span onClick={onSignUpClick} style={{ ...textColorStyle, ...boldTextStyle }}>
          Sign Up
        </span>
      </p>
      <p style={{ textAlign: 'center' }}>
        <span onClick={() => console.log('Forgot password clicked')} style={textColorStyle}>
          Forgot Password?
        </span>
      </p>

      <Alert
        isOpen={showSuccessAlert}
        onClose={() => {
          setShowSuccessAlert(false);
          history.push('/home');
        }}
        title="Success"
        content="You have logged in successfully."
        onSuccess={() => {
          setShowSuccessAlert(false);
          history.push('/home');
        }}
      />

      <Alert
        isOpen={showAlert}
        onClose={() => setShowAlert(false)}
        title="Error"
        content={error}
        onSuccess={() => {
          setShowAlert(false);
          setError('');
        }}
      />
    </div>
  );
};

interface SignUpProps {
  onLoginClick: () => void;
}

const SignUp: React.FC<SignUpProps> = ({ onLoginClick }) => {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [signedUp, setSignedUp] = useState(false);
  const [error, setError] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [showAlert, setShowAlert] = useState(false);

  const history = useHistory();

  const handleSignUp = async () => {
    try {
      const response = await fetch('http://127.0.0.1:8000/api/register-app', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ name, email, password, password_confirmation: confirmPassword }),
      });

      if (response.ok) {
        const data = await response.json();
        console.log('Sign up successful:', data);
        setShowAlert(true);
        setSignedUp(true);
        onLoginClick();
      } else {
        if (response.status === 400) {
          setError('Validation failed');
        } else {
          setError('An unexpected error occurred');
        }
        setShowAlert(true);
      }
    } catch (error) {
      console.error('Sign up error:', error);
      setError('An unexpected error occurred');
      setShowAlert(true);
    }
  };

  if (signedUp) {
    return (
      <div className="container" style={textColorStyle}>
        <h1 style={{ ...textColorStyle, ...boldTextStyle, textAlign: 'center' }}>Sign Up Successful</h1>
        <p style={{ textAlign: 'center' }}>Your account has been created successfully.</p>
        <p style={{ textAlign: 'center' }}>
          Please{' '}
          <span onClick={onLoginClick} style={{ ...textColorStyle, ...boldTextStyle }}>
            login
          </span>{' '}
          to continue.
        </p>
      </div>
    );
  }

  return (
    <div className="container" style={textColorStyle}>
      <h1 style={{ ...textColorStyle, ...boldTextStyle, textAlign: 'center' }}>Sign Up</h1>
      <IonItem style={roundedTextField}>
        <IonIcon icon={personOutline} slot="start" style={iconColorStyle} />
        <IonInput
          placeholder="Name"
          type="text"
          value={name}
          onIonChange={(e) => setName(e.detail.value!)}
          style={textColorStyle}
        />
      </IonItem>
      <div style={{ marginBottom: '16px' }} />
      <IonItem style={roundedTextField}>
        <IonIcon icon={mailOutline} slot="start" style={iconColorStyle} />
        <IonInput
          placeholder="Email"
          type="email"
          value={email}
          onIonChange={(e) => setEmail(e.detail.value!)}
          style={textColorStyle}
        />
      </IonItem>
      <div style={{ marginBottom: '16px' }} />
      <IonItem style={roundedTextField}>
        <IonIcon icon={lockClosedOutline} slot="start" style={iconColorStyle} />
        <IonInput
          placeholder="Password"
          type={showPassword ? 'text' : 'password'}
          value={password}
          onIonChange={(e) => setPassword(e.detail.value!)}
          style={textColorStyle}
        />
        <IonIcon
          icon={showPassword ? eyeOffOutline : eyeOutline}
          slot="end"
          onClick={() => setShowPassword(!showPassword)}
          style={iconColorStyle}
        />
      </IonItem>
      <div style={{ marginBottom: '16px' }} />
      <IonItem style={roundedTextField}>
        <IonIcon icon={lockClosedOutline} slot="start" style={iconColorStyle} />
        <IonInput
          placeholder="Confirm Password"
          type={showConfirmPassword ? 'text' : 'password'}
          value={confirmPassword}
          onIonChange={(e) => setConfirmPassword(e.detail.value!)}
          style={textColorStyle}
        />
        <IonIcon
          icon={showConfirmPassword ? eyeOffOutline : eyeOutline}
          slot="end"
          onClick={() => setShowConfirmPassword(!showConfirmPassword)}
          style={iconColorStyle}
        />
      </IonItem>
      <div style={{ marginBottom: '16px' }} />
      {error && <p style={{ ...textColorStyle, textAlign: 'center' }}>{error}</p>}
      <MyButton text="Sign Up" onClick={handleSignUp} />
      <p style={{ textAlign: 'center' }}>
        Already have an account?{' '}
        <span onClick={onLoginClick} style={{ ...textColorStyle, ...boldTextStyle }}>
          Login
        </span>
      </p>

      <Alert
        isOpen={showAlert}
        onClose={() => setShowAlert(false)}
        title="Error"
        content={error}
        onSuccess={() => {
          setShowAlert(false);
          setError('');
        }}
      />
    </div>
  );
};

const LoginOrSignUp = () => {
  const [showLogin, setShowLogin] = useState(true);

  const handleToggle = () => {
    setShowLogin(!showLogin);
  };

  return (
    <div>
      <h1 style={{ ...textColorStyle, ...boldTextStyle, textAlign: 'center', marginTop: 100 }}>
        Welcome to TurfScout!
      </h1>
      <div className="center-container">
        <div className={`card ${showLogin ? '' : 'is-flipped'}`} onClick={handleToggle}>
          <div className="card-inner front">
            <Login onSignUpClick={handleToggle} />
          </div>
          <div className="card-inner back">
            <SignUp onLoginClick={handleToggle} />
          </div>
        </div>
      </div>
    </div>
  );
};

export default LoginOrSignUp;
