import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Slider from 'react-slick';
import {
  IonHeader,
  IonToolbar,
  IonTitle,
  IonContent,
  IonBackButton,
  IonButtons,
  IonInfiniteScroll,
  IonInfiniteScrollContent,
  IonButton,
  IonCard,
  IonCardContent,
  IonLabel,
} from '@ionic/react';

import 'slick-carousel/slick/slick.css';
import 'slick-carousel/slick/slick-theme.css';
import '../pages/View-turfs.css'; // Import custom CSS file for styling
import MyButton from '../components/Button';

interface Turf {
  id: number;
  name: string;
  location: string;
  description: string;
  image_url: string;
  price: number;
}

const ViewTurfs: React.FC = () => {
  const [turfs, setTurfs] = useState<Turf[]>([]);
  const [page, setPage] = useState<number>(1);
  const [hasMore, setHasMore] = useState<boolean>(true);

  useEffect(() => {
    const fetchTurfs = async () => {
      try {
        const response = await axios.get(`http://127.0.0.1:8000/api/turf?page=${page}`, {
          headers: {
            Authorization: `Bearer ${localStorage.getItem('token')}`,
          },
        });
        console.log('Fetched turfs:', response.data);
        if (response.data.length === 0) {
          setHasMore(false);
          return;
        }
        setTurfs((prevTurfs) => [...prevTurfs, ...response.data]);
      } catch (error) {
        console.error('Error fetching turfs:', error);
      }
    };

    fetchTurfs();
  }, [page]);

  const loadMore = () => {
    setPage(page + 1);
  };

  const settings = {
    dots: false,
    infinite: true,
    vertical: true,
    verticalSwiping: true,
    speed: 3000, // Adjust speed for slower rotation
    slidesToShow: 3, // Show multiple slides for a circular effect
    slidesToScroll: 1,
    autoplay: true,
    autoplaySpeed: 0, // Set to 0 for continuous autoplay
    cssEase: "linear",
    centerMode: true,
    focusOnSelect: true,
    variableWidth: true, // Allow variable width slides for circular effect
  };

  const handleUpdate = (id: number) => {
    // Update logic here
  };

  const handleDelete = (id: number) => {
    // Delete logic here
  };

  const handleImageError = (event: React.SyntheticEvent<HTMLImageElement, Event>) => {
    console.error('Error loading image', event);
    (event.target as HTMLImageElement).src = '/assets/default-image.jpg';
  };

  return (
    <>
      <IonHeader>
        <IonToolbar>
          <IonButtons slot="start">
            <IonBackButton defaultHref="/home" />
          </IonButtons>
          <IonTitle>Your Turfs</IonTitle>
        </IonToolbar>
      </IonHeader>
      <IonContent className="ion-padding">
        <div className="slider-container">
          <Slider {...settings}>
            {turfs.map((turf, index) => (
              <div key={index} className="slide-card">
                <IonCard>
                  <img
                    src={`http://127.0.0.1:8000${turf.image_url}`}
                    onError={handleImageError}
                    alt={turf.name}
                    style={{ width: '100%', height: 'auto' }}
                  />
                  <IonCardContent>
                    <IonLabel>
                      <h2>{turf.name}</h2>
                      <p>{turf.location}</p>
                     <p className="price">kshs {turf.price}</p>
                      <p>{turf.description}</p> 
                    </IonLabel>
                    <div className="button-container">
    <MyButton text="Update" onClick={() => handleUpdate(turf.id)} />
    <MyButton text="Delete" onClick={() => handleDelete(turf.id)} />
  </div>
                  </IonCardContent>
                </IonCard>
              </div>
            ))}
          </Slider>
        </div>
        <IonInfiniteScroll threshold="100px" disabled={!hasMore} onIonInfinite={loadMore}>
          <IonInfiniteScrollContent loadingText="Loading more turfs..." loadingSpinner="dots" />
        </IonInfiniteScroll>
      </IonContent>
    </>
  );
};

export default ViewTurfs;
