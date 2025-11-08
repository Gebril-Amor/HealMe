// therapist-home.page.ts
import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { AlertController } from '@ionic/angular';
import { AuthService } from '../../services/auth';

@Component({
  selector: 'app-therapist-home',
  templateUrl: './therapist-home.page.html',
  styleUrls: ['./therapist-home.page.scss'],
  standalone: false
})
export class TherapistHomePage implements OnInit {
  patients: any[] = [];
  isLoading: boolean = true;

  constructor(
    private http: HttpClient,
    private router: Router,
    private alertController: AlertController,
    private authService: AuthService
  ) {}

  ngOnInit() {
    this.loadPatients();
  }

  async loadPatients() {
    try {
      const response: any = await this.http.get('http://127.0.0.1:8000/api/all-patients/').toPromise();
      this.patients = response;
    } catch (error) {
      console.error('Error loading patients:', error);
      this.showError('Failed to load patients');
    } finally {
      this.isLoading = false;
    }
  }

  openChat(patient: any) {
    this.router.navigate(['/therapist-chat', patient.patient_id], {
      state: { patient }
    });
  }

  async logout() {
    const alert = await this.alertController.create({
      header: 'Logout',
      message: 'Are you sure you want to logout?',
      buttons: [
        {
          text: 'Cancel',
          role: 'cancel'
        },
        {
          text: 'Logout',
          handler: () => {
            this.authService.logout();
            this.router.navigate(['/login']);
          }
        }
      ]
    });
    await alert.present();
  }

  private async showError(message: string) {
    const alert = await this.alertController.create({
      header: 'Error',
      message: message,
      buttons: ['OK']
    });
    await alert.present();
  }
}