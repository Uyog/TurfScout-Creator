import React from 'react';

interface MyButtonProps {
  text: string;
  onClick?: () => void;
}

const MyButton: React.FC<MyButtonProps> = ({ text, onClick, }) => {
  return (
    <button
      onClick={onClick}
      style={{
        width: '100px',
        padding: '10px',
        borderRadius: '10px',
        backgroundColor: '#97FB57',
        cursor: 'pointer',
        textAlign: 'center',
        fontWeight: 'bold',
        color: '#121212',
        margin: '0 auto',
        border: 'none',
      }}
    >
      {text}
    </button>
  );
};

export default MyButton;
