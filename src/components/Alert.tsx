import React from 'react';
import Lottie from 'react-lottie';
import successAnimation from '../components/Tick.json'; 
import errorAnimation from '../components/Failed.json'; 

interface AlertProps {
  isOpen: boolean;
  type: 'success' | 'error';
  content: string;
  onClose: () => void;
}

const Alert: React.FC<AlertProps> = ({ isOpen, type, content, onClose }) => {
  if (!isOpen) return null;

  const animationData = type === 'success' ? successAnimation : errorAnimation;
  const defaultOptions = {
    loop: false,
    autoplay: true,
    animationData: animationData,
    rendererSettings: {
      preserveAspectRatio: 'xMidYMid slice',
    },
  };

  const overlayStyle: React.CSSProperties = {
    position: 'fixed',
    top: 0,
    left: 0,
    width: '100%',
    height: '100%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    zIndex: 9999, // Set a high z-index to ensure the alert is on top of other content
  };

  const alertBoxStyle: React.CSSProperties = {
    backgroundColor: '#000',
    color: '#0f0',
    borderRadius: '10px',
    padding: '20px',
    textAlign: 'center',
    width: '300px',
  };

  const messageStyle: React.CSSProperties = {
    margin: '20px 0',
  };

  const buttonStyle: React.CSSProperties = {
    backgroundColor: '#0f0',
    color: '#000',
    border: 'none',
    borderRadius: '5px',
    padding: '10px 20px',
    cursor: 'pointer',
  };

  return (
    <div style={overlayStyle}>
      <div style={alertBoxStyle}>
        <Lottie options={defaultOptions} height={100} width={100} />
        <p style={messageStyle}>{content}</p>
        <button onClick={onClose} style={buttonStyle}>OK</button>
      </div>
    </div>
  );
};

export default Alert;
