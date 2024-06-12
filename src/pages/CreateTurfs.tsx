import React, { useState, useRef } from 'react';
import axios from 'axios';
import { IonBackButton, IonButtons, IonInput, IonTextarea, IonItem, IonIcon, IonLabel, IonHeader, IonToolbar, IonTitle, IonContent } from '@ionic/react';
import { imageOutline, locationOutline, pricetagOutline, documentTextOutline, layersOutline, trophyOutline } from 'ionicons/icons';
import './CreateTurfs.css';
import MyButton from '../components/Button';

const roundedTextField = {
  borderRadius: '20px',
  marginBottom: '16px',
};

const iconColorStyle = {
  color: '#97FB57',
};

const textColorStyle = {
  color: '#97FB57',
};

const CreateTurfs: React.FC = () => {
  const [formData, setFormData] = useState({
    name: '',
    location: '',
    description: '',
    image: null as File | null,
    price: 0,
    numberOfPitches: 1,
  });

  const [message, setMessage] = useState('');
  const [error, setError] = useState('');
  const [imagePreview, setImagePreview] = useState<string | null>(null);
  
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleChange = (e: any) => {
    const { name, value } = e.target;
    setFormData({ ...formData, [name]: value });
  };

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files.length > 0) {
      setFormData({ ...formData, image: e.target.files[0] });
      setImagePreview(URL.createObjectURL(e.target.files[0]));
    }
  };

  const handleSubmit = async (e?: React.FormEvent<HTMLFormElement>) => {
    if (e) e.preventDefault();

    const postData = new FormData();
    postData.append('name', formData.name);
    postData.append('location', formData.location);
    postData.append('description', formData.description);
    if (formData.image) {
      postData.append('image', formData.image);
    }
    postData.append('price', formData.price.toString());
    postData.append('number_of_pitches', formData.numberOfPitches.toString());

    try {
      const response = await axios.post('http://127.0.0.1:8000/api/turf', postData, {
        headers: {
          'Content-Type': 'multipart/form-data',
          Authorization: `Bearer ${localStorage.getItem('token')}`,
        },
      });
      setMessage('Your turf has been created successfully!');
      setError('');
      console.log('Turf created:', response.data);
    } catch (error: any) {
      if (error.response) {
        console.error('Error creating turf:', error.response.data);
        console.error('Status:', error.response.status);
      } else if (error.request) {
        console.error('Error creating turf:', error.request);
      } else {
        console.error('Error creating turf:', error.message);
      }
      setError('Failed to create your turf! Try again later.');
      setMessage('');
    }
  };

  return (
    <div className="create-turf-container">
      <IonHeader>
        <IonToolbar>
          <IonButtons slot="start">
            <IonBackButton defaultHref="/home" />
          </IonButtons>
          <IonTitle>Create Turf</IonTitle>
        </IonToolbar>
      </IonHeader>
      <IonContent>
        <form onSubmit={handleSubmit} className="create-turf-form">
          <div className="form-group">
            <IonLabel>Image:</IonLabel>
            <input 
              type="file" 
              accept="image/*" 
              onChange={handleImageChange} 
              ref={fileInputRef} 
              style={{ display: 'none' }} 
              required 
            />
            <MyButton 
              text="Choose file" 
              onClick={() => fileInputRef.current?.click()} 
            />
            {imagePreview && <img src={imagePreview} alt="Preview" className="image-preview" />}
          </div>
          <div className="name-price-container">
            <IonItem style={roundedTextField} className="ion-text-field name-input">
              <IonIcon icon={trophyOutline} slot="start" style={iconColorStyle} />
              <IonInput
                name="name"
                placeholder="Name"
                value={formData.name}
                onIonChange={handleChange}
                required
                style={textColorStyle}
                className="custom-placeholder"
              />
            </IonItem>
            <IonItem style={roundedTextField} className="ion-text-field price-input">
              <IonIcon icon={pricetagOutline} slot="start" style={iconColorStyle} />
              <IonInput
                type="number"
                name="price"
                placeholder="Price"
                value={formData.price}
                onIonChange={handleChange}
                required
                style={textColorStyle}
                className="custom-placeholder"
              />
            </IonItem>
          </div>
          <IonItem style={roundedTextField} className="ion-text-field">
            <IonIcon icon={locationOutline} slot="start" style={iconColorStyle} />
            <IonInput
              name="location"
              placeholder="Location"
              value={formData.location}
              onIonChange={handleChange}
              required
              style={textColorStyle}
              className="custom-placeholder"
            />
          </IonItem>
          <IonItem style={roundedTextField} className="ion-text-field">
            <IonIcon icon={documentTextOutline} slot="start" style={iconColorStyle} />
            <IonTextarea
              name="description"
              placeholder="Description"
              value={formData.description}
              onIonChange={handleChange}
              required
              style={textColorStyle}
              className="custom-placeholder"
            />
          </IonItem>
          <IonItem style={roundedTextField} className="ion-text-field">
            <IonIcon icon={layersOutline} slot="start" style={iconColorStyle} />
            <IonInput
              type="number"
              name="numberOfPitches"
              placeholder="Number of pitches"
              value={formData.numberOfPitches}
              onIonChange={handleChange}
              required
              style={textColorStyle}
              className="custom-placeholder"
            />
          </IonItem>
          <MyButton text="Create" onClick={handleSubmit} />
        </form>
        {message && <div className="success-message">{message}</div>}
        {error && <div className="error-message">{error}</div>}
      </IonContent>
    </div>
  );
};

export default CreateTurfs;
