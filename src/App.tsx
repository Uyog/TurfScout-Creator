import React, { useState, useEffect } from 'react';
import SplashScreen from '../src/pages/Splash';
import Auth from './pages/Auth';
import Home from '../src/pages/Home';
import './components/Alert.css';
import { Redirect, Route } from 'react-router-dom';
import {
  IonApp,
  IonIcon,
  IonLabel,
  IonRouterOutlet,
  IonTabBar,
  IonTabButton,
  IonTabs,
  setupIonicReact
} from '@ionic/react';
import { IonReactRouter } from '@ionic/react-router';
import { ellipse, home, search, settings, square, triangle } from 'ionicons/icons';
import Splash from '../src/pages/Splash';
import AuthPage from './pages/Auth';
import ForgotPassword from '../src/pages/ForgotPassword';
import HomePage from '../src/pages/Home';
import CreateTurfs from '../src/pages/Create-turfs';
import ViewTurfs from '../src/pages/View-turfs';


/* Core CSS required for Ionic components to work properly */
import '@ionic/react/css/core.css';

/* Basic CSS for apps built with Ionic */
import '@ionic/react/css/normalize.css';
import '@ionic/react/css/structure.css';
import '@ionic/react/css/typography.css';

/* Optional CSS utils that can be commented out */
import '@ionic/react/css/padding.css';
import '@ionic/react/css/float-elements.css';
import '@ionic/react/css/text-alignment.css';
import '@ionic/react/css/text-transformation.css';
import '@ionic/react/css/flex-utils.css';
import '@ionic/react/css/display.css';

/**
 * Ionic Dark Mode
 * -----------------------------------------------------
 * For more info, please see:
 * https://ionicframework.com/docs/theming/dark-mode
 */

/* import '@ionic/react/css/palettes/dark.always.css'; */
/* import '@ionic/react/css/palettes/dark.class.css'; */
import '@ionic/react/css/palettes/dark.system.css';

/* Theme variables */
import './theme/variables.css';

setupIonicReact();

const App: React.FC = () => {
  const [loading, setLoading] = useState(true);
  const [authenticated, setAuthenticated] = useState(false);

  useEffect(() => {
    setTimeout(() => {
      setLoading(false);
    }, 3000);
  }, []);

  useEffect(() => {
    const token = localStorage.getItem('token');
    setAuthenticated(!!token);
  }, []);

  const handleAuthentication = (isAuthenticated: boolean) => {
    setAuthenticated(isAuthenticated);
  };

  const handleAnimationComplete = () => {
    console.log('Animation completed');
  };

  return (
    <IonApp>
      {loading ? (
        <SplashScreen onAnimationComplete={handleAnimationComplete} />
      ) : (
        <IonReactRouter>
          <IonRouterOutlet>
            <Route path="/auth" component={AuthPage} exact />
            <Route path="/home" component={HomePage} exact />
            <Route path="/forgot-password" component={ForgotPassword} exact />
            <Route path="/create" component={CreateTurfs} exact />
            <Route path="/view" component={ViewTurfs} exact />
            <Route path="/forgot-password" component={ForgotPassword} exact />
            <Route exact path="/">
              {authenticated ? <Redirect to="/home" /> : <Redirect to="/auth" />}
            </Route>
          </IonRouterOutlet>
        </IonReactRouter>
      )}
    </IonApp>
  );
};

export default App;