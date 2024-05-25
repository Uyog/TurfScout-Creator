import React from 'react';
import { IonAlert } from '@ionic/react';

interface AlertProps {
  isOpen: boolean;
  onClose: () => void;
  title?: string;
  content: string;
  onSuccess: () => void;
}

const Alert: React.FC<AlertProps> = ({ isOpen, onClose, title, content, onSuccess }) => {
  return (
    <IonAlert
      isOpen={isOpen}
      onDidDismiss={onClose}
      header={title}
      message={content}
      buttons={[
        {
          text: 'OK', 
          handler: onSuccess,
        },
      ]}
      cssClass="custom-alert" 
      backdropDismiss={false} 
      translucent 
      style={{ '--ion-color-base': '#97FB57' }} 
    />
  );
};

export default Alert;
