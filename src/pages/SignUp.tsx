import React, { useState } from 'react';
import MyButton from '../components/Button';
import Alert from '../components/Alert';
import { IonInput, IonItem, IonIcon } from '@ionic/react';
import { eyeOffOutline, eyeOutline, lockClosedOutline, mailOutline, personOutline } from 'ionicons/icons';
import { useHistory } from 'react-router-dom';
import Lottie from 'react-lottie';
import loadingAnimation from '../components/Loading2.json';

interface SignUpProps {
    onLoginClick: () => void;
}

const roundedTextField = {
    borderRadius: '20px',
    marginBottom: '16px', // Add margin bottom to space out the fields
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
    const [loading, setLoading] = useState(false);
    const [alertType, setAlertType] = useState<'success' | 'error'>('error');

    const history = useHistory();

    const handleSignUp = async () => {
        try {
            setLoading(true);
            const response = await fetch('http://127.0.0.1:8000/api/register-app', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ name, email, password, password_confirmation: confirmPassword })
            });

            if (response.ok) {
                const data = await response.json();
                console.log('Sign up successful:', data);
                setAlertType('success');
                setShowAlert(true);
                setSignedUp(true);
            } else {
                if (response.status === 400) {
                    setError('Validation failed. Please check your input and try again.');
                } else {
                    setError('An unexpected error occurred. Please try again.');
                }
                setAlertType('error');
                setShowAlert(true);
            }
        } catch (error) {
            console.error('Sign up error:', error);
            setError('An unexpected error occurred. Please try again later.');
            setAlertType('error');
            setShowAlert(true);
        } finally {
            setLoading(false);
        }
    };

    if (signedUp) {
        return (
            <div className="container" style={textColorStyle}>
                <h1 style={{ ...textColorStyle, ...boldTextStyle, textAlign: 'center' }}>Sign Up Successful</h1>
                <p style={{ textAlign: 'center' }}>Your account has been created successfully.</p>
                <p style={{ textAlign: 'center' }}>Please <span onClick={onLoginClick} style={{ ...textColorStyle, ...boldTextStyle }}>login</span> to continue.</p>
            </div>
        );
    }

    return (
        <div className="container" style={textColorStyle}>
            {loading && (
                <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
                    <Lottie options={{ animationData: loadingAnimation }} width={100} height={100} />
                </div>
            )}
            <h1 style={{ ...textColorStyle, ...boldTextStyle, textAlign: 'center' }}>Sign Up</h1>
            <IonItem style={roundedTextField}>
                <IonIcon icon={personOutline} slot="start" style={iconColorStyle} />
                <IonInput
                    placeholder='Name'
                    type="text"
                    value={name}
                    onIonChange={(e) => setName(e.detail.value!)}
                    style={textColorStyle}
                />
            </IonItem>
            <IonItem style={roundedTextField}>
                <IonIcon icon={mailOutline} slot="start" style={iconColorStyle} />
                <IonInput
                    placeholder='Email'
                    type="email"
                    value={email}
                    onIonChange={(e) => setEmail(e.detail.value!)}
                    style={textColorStyle}
                />
            </IonItem>
            <IonItem style={roundedTextField}>
                <IonIcon icon={lockClosedOutline} slot="start" style={iconColorStyle} />
                <IonInput
                    placeholder='Password'
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
            <IonItem style={roundedTextField}>
                <IonIcon icon={lockClosedOutline} slot="start" style={iconColorStyle} />
                <IonInput
                    placeholder='Confirm Password'
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
            {error && <p style={{ ...textColorStyle, textAlign: 'center' }}>{error}</p>}
            <MyButton text="Sign Up" onClick={handleSignUp} />
            <p style={{ textAlign: 'center' }}>Already have an account? <span onClick={onLoginClick} style={{ ...textColorStyle, ...boldTextStyle }}>Login</span></p>

            <Alert
                isOpen={showAlert}
                type={alertType}
                content={alertType === 'success' ? 'Sign up successful!' : error}
                onClose={() => setShowAlert(false)}
            />
        </div>
    );
};

export default SignUp;
