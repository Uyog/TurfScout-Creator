import React, { useState, useRef } from 'react';
import axios from 'axios';
import {
  IonBackButton,
  IonButtons,
  IonInput,
  IonTextarea,
  IonItem,
  IonHeader,
  IonToolbar,
  IonTitle,
  IonContent,
  IonIcon,
  IonLoading
} from '@ionic/react';
import { personCircle, locationSharp, pricetag, list, layers } from 'ionicons/icons';
import './CreateTurfs.css';
import MyButton from '../components/Button';
import LottieAnimation from 'react-lottie';
import LoadingAnimation from '../components/Loading2.json';

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
  const [loading, setLoading] = useState(false); 

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

    setLoading(true);

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
    } finally {
      setLoading(false); 
    }
  };

  return (
    <div className="create-turf-container">
      <IonHeader>
        <IonToolbar>
          <IonButtons style={{ color: '#97FB57' }} slot="start">
            <IonBackButton defaultHref="/home" />
          </IonButtons>
          <IonTitle style={{ color: '#97FB57' }}>Create Turf</IonTitle>
        </IonToolbar>
      </IonHeader>
      <IonContent>
        <form onSubmit={handleSubmit} className="create-turf-form">
          <div className="form-group form-fields">
            <input
              type="file"
              accept="image/*"
              onChange={handleImageChange}
              ref={fileInputRef}
              style={{ display: 'none' }}
              required
            />
            <MyButton
              text="Image"
              onClick={() => fileInputRef.current?.click()}
            />
            {imagePreview && <img src={imagePreview} alt="Preview" className="image-preview" />}
          </div>
          <div className="form-fields">
            <IonItem className="ion-text-field half-width">
              <IonIcon icon={personCircle} slot="start" />
              <IonInput
                name="name"
                placeholder="Name"
                value={formData.name}
                onIonChange={handleChange}
                required
              />
            </IonItem>
            <IonItem className="ion-text-field half-width">
              <IonIcon icon={pricetag} slot="start" />
              <IonInput
                type="number"
                name="price"
                placeholder="Price"
                value={formData.price}
                onIonChange={handleChange}
                required
              />
            </IonItem>
            <IonItem className="ion-text-field full-width">
              <IonIcon icon={locationSharp} slot="start" />
              <IonInput
                name="location"
                placeholder="Location"
                value={formData.location}
                onIonChange={handleChange}
                required
              />
            </IonItem>
            <IonItem className="ion-text-field full-width">
              <IonIcon icon={list} slot="start" />
              <IonTextarea
                name="description"
                placeholder="Description"
                value={formData.description}
                onIonChange={handleChange}
                required
              />
            </IonItem>
            <IonItem className="ion-text-field pitches">
              <IonIcon icon={layers} slot="start" />
              <IonInput
                type="number"
                name="numberOfPitches"
                placeholder="Pitches"
                value={formData.numberOfPitches}
                onIonChange={handleChange}
                required
              />
            </IonItem>
          </div>
          <MyButton text="Create" onClick={handleSubmit} />
        </form>
        {message && <div className="success-message">{message}</div>}
        {error && <div className="error-message">{error}</div>}
        <IonLoading
          isOpen={loading}
          message={'Please wait...'}
        />
      </IonContent>
    </div>
  );
};

export default CreateTurfs;
