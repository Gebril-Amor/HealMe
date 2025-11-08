// src/app/pages/register/register.page.ts
import { Component } from '@angular/core';
import { AuthService } from '../../services/auth';
import { Router } from '@angular/router';
import { LoadingController, ToastController } from '@ionic/angular';

@Component({
  selector: 'app-register',
  templateUrl: './register.page.html',
  styleUrls: ['./register.page.scss'],
  standalone: false
})
export class RegisterPage {
  registerData = {
    username: '',
    email: '',
    password: '',
    user_type: 'patient'
  };

  userTypes = [
    { value: 'patient', label: 'Patient' },
    { value: 'therapeute', label: 'Thérapeute' },
    { value: 'administrateur', label: 'Administrateur' }
  ];

  // Single profile data object
  profileData: any = {};

  constructor(
    private authService: AuthService,
    private router: Router,
    private loadingCtrl: LoadingController,
    private toastCtrl: ToastController
  ) {
    this.initializeProfileData();
  }

  initializeProfileData() {
    // Initialize based on current user type
    switch (this.registerData.user_type) {
      case 'patient':
        this.profileData = { phone: '', dateNaissance: '' };
        break;
      case 'therapeute':
        this.profileData = { specialite: '', phone: '' };
        break;
      case 'administrateur':
        this.profileData = { departement: '' };
        break;
      default:
        this.profileData = {};
    }
  }

  async register() {
    const loading = await this.loadingCtrl.create({
      message: 'Création du compte...'
    });
    await loading.present();

    // Create the data object with ALL required fields
    const dataToSend = {
      username: this.registerData.username,
      email: this.registerData.email,
      password: this.registerData.password,
      user_type: this.registerData.user_type, // Make sure this is included
      profile_data: { ...this.profileData }
    };

    console.log('Sending registration data:', dataToSend);

    this.authService.register(dataToSend).subscribe({
      next: async (response) => {
        await loading.dismiss();
        console.log('Registration successful:', response);
        
        const toast = await this.toastCtrl.create({
          message: 'Compte créé avec succès!',
          duration: 2000,
          color: 'success'
        });
        await toast.present();
        this.navigateToHome(response.user.user_type);
      },
      error: async (error: any) => {
        await loading.dismiss();
        console.error('Registration error:', error);
        
        const toast = await this.toastCtrl.create({
          message: error.error?.error || 'Erreur lors de la création du compte',
          duration: 3000,
          color: 'danger'
        });
        await toast.present();
      }
    });
  }

  private navigateToHome(userType: string) {
    switch (userType) {
      case 'patient':
        this.router.navigate(['/tabs']);
        break;
    case 'therapeute':
      this.router.navigate(['/therapist-home']);  // Updated
      break;
      case 'administrateur':
        this.router.navigate(['/admin-home']);
        break;
      default:
        this.router.navigate(['/home']);
    }
  }

  onUserTypeChange() {
    console.log('User type changed to:', this.registerData.user_type);
    this.initializeProfileData();
  }
}