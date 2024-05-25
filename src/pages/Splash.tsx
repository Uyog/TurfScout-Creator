import React, { useState, useEffect } from 'react';
import Lottie from 'react-lottie';
import animationData from '../components/Creator.json';

interface SplashScreenProps {
  onAnimationComplete: () => void;
}

const SplashScreen: React.FC<SplashScreenProps> = ({ onAnimationComplete }) => {
  const [showAnimation, setShowAnimation] = useState(true);

  useEffect(() => {
    const timeout = setTimeout(() => {
      setShowAnimation(false);
      onAnimationComplete(); 
    }, 2000); 

    return () => clearTimeout(timeout);
  }, []);

  const defaultOptions = {
    loop: false,
    autoplay: true,
    animationData: animationData,
    rendererSettings: {
      preserveAspectRatio: 'xMidYMid slice'
    }
  };

  return (
    <div
      className="SplashScreen"
      style={{
        backgroundColor: '#000000',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        height: '100vh', 
      }}
    >
      {showAnimation && (
        <Lottie
          options={defaultOptions}
          height={400}
          width={400}
          eventListeners={[
            {
              eventName: 'complete',
              callback: onAnimationComplete,
            },
          ]}
        />
      )}
    </div>
  );
};

export default SplashScreen;
