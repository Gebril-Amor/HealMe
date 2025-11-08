import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { AlertController } from '@ionic/angular';
import { Share } from '@capacitor/share';
import { AuthService } from '../../services/auth';

@Component({
  selector: 'app-therapists-list',
  templateUrl: './therapist-list.page.html',
  styleUrls: ['./therapist-list.page.scss'],
  standalone: false
})
export class TherapistListPage implements OnInit {
  therapists: any[] = [];
  isLoading: boolean = true;

  constructor(
    private http: HttpClient,
    private router: Router,
    private alertController: AlertController,
    private authService: AuthService
  ) {}

  ngOnInit() {
    this.loadTherapists();
  }

  async loadTherapists() {
    try {
      const response: any = await this.http.get('http://127.0.0.1:8000/api/therapists/').toPromise();
      this.therapists = response;
    } catch (error) {
      console.error('Error loading therapists:', error);
      this.showError('Failed to load therapists');
    } finally {
      this.isLoading = false;
    }
  }

  openChat(therapist: any) {
    this.router.navigate(['/chat', therapist.id], {
      state: { therapist }
    });
  }

  async shareTherapist(therapist: any, event: Event) {
    event.stopPropagation(); // Prevent opening chat when sharing
    
    try {
      const canShare = await Share.canShare();
      
      if (!canShare.value) {
        this.showError('Sharing is not available on this device');
        return;
      }

      await Share.share({
        title: `Therapist: ${therapist.user?.username || therapist.name}`,
        text: `Check out this therapist: ${therapist.user?.username || therapist.name}. ${therapist.specialite || 'Mental health professional'}`,
        url: 'https://yourapp.com/therapists', // Replace with your actual app URL
        dialogTitle: 'Share Therapist Information'
      });
      
    } catch (error) {
      console.error('Error sharing therapist:', error);
      this.showError('Failed to share therapist information');
    }
  }

  // Alternative share method with more detailed information
  async shareTherapistDetails(therapist: any, event: Event) {
    event.stopPropagation();
    
    try {
      const therapistInfo = `
👨‍⚕️ Therapist Information:

Name: ${therapist.user?.username || 'N/A'}
Specialty: ${therapist.specialite || 'Mental Health'}
Email: ${therapist.user?.email || 'N/A'}
Experience: ${therapist.annees_experience || 'N/A'} years

Available for consultations and therapy sessions.
Download our app to book an appointment!
      `.trim();

      await Share.share({
        title: `Therapist Profile - ${therapist.user?.username}`,
        text: therapistInfo,
        url: 'https://yourapp.com/therapists',
        dialogTitle: 'Share Therapist Profile'
      });
      
    } catch (error) {
      console.error('Error sharing therapist details:', error);
      this.showError('Failed to share therapist profile');
    }
  }

  // Simple share for basic info
  async quickShareTherapist(therapist: any, event: Event) {
    event.stopPropagation();
    
    try {
      await Share.share({
        text: `Check out ${therapist.user?.username || 'this therapist'} on our mental health app!`,
        url: 'https://yourapp.com/therapists',
      });
    } catch (error) {
      console.error('Quick share failed:', error);
    }
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