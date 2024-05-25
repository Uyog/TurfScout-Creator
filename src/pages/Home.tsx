import React, { useState, useEffect } from 'react';
import {  IonFooter, IonButtons, IonContent, IonHeader, IonMenu, IonMenuButton, IonPage, IonTitle, IonToolbar, IonAvatar, IonButton, IonCard, IonCardContent, IonCardHeader, IonCardSubtitle, IonCardTitle, IonGrid, IonRow, IonCol, IonFab, IonFabButton, IonFabList, IonIcon } from '@ionic/react';
import { add, eye, people, person, search, settings } from 'ionicons/icons';
import { useHistory } from 'react-router-dom';
import Lottie from 'react-lottie';
import animationData from '../components/Creator.json';
import { Redirect } from 'react-router-dom';
import Slider from 'react-slick';
import 'slick-carousel/slick/slick.css';
import 'slick-carousel/slick/slick-theme.css';
import './Home.css';

interface User {
  id: number;
  name: string;
  email: string;
}

interface HomePageProps {
  authenticated: boolean;
}



const HomePage: React.FC<HomePageProps> = ({ authenticated }) => {
  const [userName, setUserName] = useState<string>(""); 
  const [user, setUser] = useState<User | null>(null);
  const history = useHistory();

  useEffect(() => {
    const fetchUserData = async () => {
      try {
        const token = localStorage.getItem('token');
        const response = await fetch('http://127.0.0.1:8000/api/user', {
          method: 'GET',
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json',
          },
        });

        if (response.ok) {
          const userData = await response.json();
          setUserName(userData.name); 
        } else {
          console.error('Failed to fetch user data');
        }
      } catch (error) {
        console.error('Failed to fetch user data:', error);
      }
    };

    fetchUserData(); 
  }, []);

  const handleLogout = async () => {
    try {
      console.log('Logging out...');
  
      const token = localStorage.getItem('token');
      console.log('Token before removal:', token);
  
      const response = await fetch('http://127.0.0.1:8000/api/logout', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      });
  
      if (response.ok) {
        console.log('Logged out successfully');
        localStorage.removeItem('token');
        console.log('Token removed');
        window.location.href = '/auth';
      } else {
        console.error('Logout failed:', response.statusText);
      }
    } catch (error) {
      console.error('Logout failed:', error);
    }
    if (!authenticated) {
      return <Redirect to="/" />;
    }
  };

  const sampleData = [
    { id: 1, title: "Title 1", subtitle: "Subtitle 1", content: "Content 1" },
    { id: 2, title: "Title 2", subtitle: "Subtitle 2", content: "Content 2" },
    { id: 3, title: "Title 3", subtitle: "Subtitle 3", content: "Content 3" },
    // Add more sample data as needed
  ];

  const settings = {
    dots: true,
    infinite: true,
    speed: 500,
    slidesToShow: 1,
    slidesToScroll: 1,
    autoplay: true, // Enable autoplay
    autoplaySpeed: 3000, // Set autoplay speed (in milliseconds)
  };
 

  

  return (
    <>
      <IonMenu contentId="main-content">
        <IonHeader>
          <IonToolbar color="black">
            <IonTitle style={{ color: '#97FB57',}}>TurfScout</IonTitle>
          </IonToolbar>
        </IonHeader>
        <IonContent className="ion-padding">
        
           </IonContent>
        <IonFooter>
          <IonToolbar>
          <IonButton color="light" expand="full" onClick={handleLogout} style={{ backgroundColor: '#97FB57', color: 'black', fontWeight: 'bold', '--ion-color-light': '#97FB57', '--ion-color-light-contrast': 'black' }}>Logout</IonButton>
          </IonToolbar>
        </IonFooter>
      </IonMenu>
      <IonPage id="main-content">
        <IonHeader>
          <IonToolbar>
            <IonButtons slot="start">
              <IonMenuButton style={{ color: '#97FB57',}}></IonMenuButton>
            </IonButtons>
            <IonTitle style={{ color: '#97FB57',}}>TurfScout</IonTitle>
          </IonToolbar>
        </IonHeader>
        <IonContent>
          <IonCard color="dark" style={{ backgroundColor: 'black' }}>
            <IonCardHeader></IonCardHeader>
            <IonCardContent>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'flex-start' }}>
              <Lottie
            options={{
              loop: true,
              autoplay: true,
              animationData: animationData,
              rendererSettings: {
                preserveAspectRatio: 'xMidYMid slice'
              }
            }}
            height={150} 
            width={150} 
          />
                <span style={{ color: '#97FB57', fontWeight: 'bold', fontSize: 30, marginLeft: 40 }}>Welcome {userName}!</span>
              </div>
            </IonCardContent>
            <h4 style={{ color: '#97FB57', fontWeight: 'bold', fontSize: 20, marginLeft: 20 }}>Create A Turf Today!</h4>
          </IonCard>
          <h2 style={{ color: '#97FB57', fontWeight: 'bold', fontSize: 25, marginLeft: 20 }}>Best Turfs</h2>
            
             {/* Carousel Slider */}
             <Slider {...settings} className="custom-slider">
  {sampleData.map((item) => (
    <div key={item.id} className="slider-item"> {/* Move key prop to outer div */}
      <IonCard className="custom-card">
        <IonCardHeader>
          <IonCardSubtitle>{item.subtitle}</IonCardSubtitle>
          <IonCardTitle>{item.title}</IonCardTitle>
        </IonCardHeader>
        <IonCardContent>
          <p>{item.content}</p>
        </IonCardContent>
      </IonCard>
    </div>
  ))}
</Slider>


          <FabButton history={history} /> 
        </IonContent>
      </IonPage>
    </>
  );
};



interface FabButtonProps {
  history: any; 
}

const FabButton: React.FC<FabButtonProps> = ({ history }) => (
  <IonFab vertical="bottom" horizontal="end" style={{ marginBottom: '20px', marginRight: '20px', position: 'fixed', zIndex: '9999' }}>
    <IonFabButton>
      <IonIcon icon={add}></IonIcon>
    </IonFabButton>
    <IonFabList side="start">
      <IonFabButton onClick={() => history.push('/create')}> 
        <IonIcon icon={add}></IonIcon>
      </IonFabButton>
      <IonFabButton onClick={() => history.push('/profile')}> 
        <IonIcon icon={person}></IonIcon>
      </IonFabButton>
      <IonFabButton onClick={() => history.push('/view')}> 
        <IonIcon icon={eye}></IonIcon>
      </IonFabButton>

    </IonFabList>
  </IonFab>
);

export default HomePage;
