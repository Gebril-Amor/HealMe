// src/app/pages/login/login.page.ts
import { Component } from '@angular/core';
import { AuthService } from '../../services/auth';
import { Router } from '@angular/router';
import { LoadingController, ToastController } from '@ionic/angular';
import { environment } from 'src/environments/environment';
@Component({
  selector: 'app-login',
  templateUrl: './login.page.html',
  styleUrls: ['./login.page.scss'],
  standalone: false
})
export class LoginPage {
  loginData = {
    email: '',
    password: ''
  };

  showPassword = false;
  public apiUrl=environment.apiUrl;
  constructor(
    private authService: AuthService,
    private router: Router,
    private loadingCtrl: LoadingController,
    private toastCtrl: ToastController
  ) {}



  async login() {
    const loading = await this.loadingCtrl.create({
      message: 'Signing in...',
      spinner: 'crescent'
    });
    await loading.present();

    this.authService.login(this.loginData).subscribe({
      next: async (response) => {
        await loading.dismiss();
        
        const toast = await this.toastCtrl.create({
          message: 'Login successful!',
          duration: 2000,
          color: 'success',
          position: 'top'
        });
        await toast.present();

        this.navigateToHome(response.user.user_type);
      },
      error: async (error: any) => {
        await loading.dismiss();
        
        const toast = await this.toastCtrl.create({
          message: error.error?.error || 'Login failed. Please check your credentials.',
          duration: 3000,
          color: 'danger',
          position: 'top'
        });
        await toast.present();
      }
    });
  }

  togglePassword() {
    this.showPassword = !this.showPassword;
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
}