// therapist-chat.page.ts
import { Component, OnInit, ViewChild } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { HttpClient } from '@angular/common/http';
import { IonContent, Platform } from '@ionic/angular';
import { AuthService } from '../../services/auth';

@Component({
  selector: 'app-therapist-chat',
  templateUrl: './therapist-chat.page.html',
  styleUrls: ['./therapist-chat.page.scss'],
  standalone: false
})
export class TherapistChatPage implements OnInit {
  @ViewChild(IonContent) content!: IonContent;
  
  messages: any[] = [];
  newMessage: string = '';
  patient: any = null;
  patientId: number = 0;
  therapistId: number = 0;
  isLoading: boolean = true;
  private messageInterval: any;
  currentUser: any;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private http: HttpClient,
    private authService: AuthService,
    private platform: Platform
  ) {}

  async ngOnInit() {
    this.patientId = +this.route.snapshot.paramMap.get('id')!;
    this.patient = history.state.patient;
    
    this.currentUser = this.authService.getCurrentUser();
    
    // Get therapist ID from current user
    if (this.currentUser) {
      this.therapistId = this.currentUser.id; // This is the therapist ID
      console.log('Current user ID (therapistId):', this.therapistId);
      console.log('Patient ID:', this.patientId);
    }
    
    await this.loadMessages();
    this.setupRealTimeUpdates();
  }

  async loadMessages() {
    if (!this.patientId || !this.therapistId) {
      console.error('Missing patientId or therapistId');
      console.log('patientId:', this.patientId, 'therapistId:', this.therapistId);
      this.isLoading = false;
      return;
    }

    try {
      console.log('Loading messages for therapist:', this.therapistId, 'patient:', this.patientId);
      
      const response: any = await this.http.get(
        `http://127.0.0.1:8000/api/conversation/${this.patientId}/${this.therapistId}/`
      ).toPromise();
      
      console.log('Messages loaded:', response);
      this.messages = response;
      this.scrollToBottom();
    } catch (error: any) {
      console.error('Error loading messages:', error);
      
      // If the new endpoint doesn't exist, try the old one
      if (error.status === 404) {
        console.log('New endpoint not found, trying fallback...');
        await this.loadMessagesFallback();
      }
    } finally {
      this.isLoading = false;
    }
  }

  // Fallback to the original endpoint
  async loadMessagesFallback() {
    try {
      console.log('Trying fallback endpoint with conversation API...');
      
      // Use the conversation endpoint with patientId and therapistId
      const response: any = await this.http.get(
        `http://127.0.0.1:8000/api/conversation/${this.patientId}/${this.therapistId}/`
      ).toPromise();
      
      console.log('Fallback conversation messages:', response);
      this.messages = response;
      this.scrollToBottom();
    } catch (error) {
      console.error('Conversation endpoint failed:', error);
      
      // Try the original messages endpoint as last resort
      try {
        console.log('Trying original messages endpoint...');
        const response: any = await this.http.get(
          `http://127.0.0.1:8000/api/messages/?therapist_id=${this.therapistId}`
        ).toPromise();
        console.log('Original messages endpoint response:', response);
        this.messages = response;
        this.scrollToBottom();
      } catch (finalError) {
        console.error('All endpoints failed:', finalError);
        // Load mock data for testing
        this.loadMockMessages();
      }
    }
  }

  async sendMessage() {
    if (!this.newMessage.trim() || !this.therapistId || !this.patientId) return;

    try {
      const messageData = {
        contenu: this.newMessage.trim(),
        therapist_id: this.therapistId,
        patient_id: this.patientId,
        sender_type: 'therapeute'  // Therapist is sending
      };

      console.log('Sending message as therapist:', messageData);

      // Use the new send-message endpoint
      const response: any = await this.http.post(
        'http://127.0.0.1:8000/api/send-message/',
        messageData
      ).toPromise();

      console.log('Message sent successfully:', response);

      // Add the new message to the list
      this.messages.push(response);
      this.newMessage = '';
      this.scrollToBottom();

    } catch (error: any) {
      console.error('Error sending message:', error);
      
      // Fallback: try the old endpoint
      if (error.status === 404) {
        console.log('New send endpoint not found, trying fallback...');
        await this.sendMessageFallback();
      }
    }
  }

  // Update sendMessageFallback to also use real IDs
  async sendMessageFallback() {
    try {
      const messageData = {
        contenu: this.newMessage.trim(),
        therapeute: this.therapistId,
        patient_id: this.patientId,
        sender_type: 'therapeute'
      };

      console.log('Sending via fallback with therapist ID:', this.therapistId);

      const response: any = await this.http.post(
        'http://127.0.0.1:8000/api/messages/', 
        messageData
      ).toPromise();

      console.log('Fallback send successful:', response);
      
      // Add the response message to the list
      this.messages.push(response);
      this.newMessage = '';
      this.scrollToBottom();
    } catch (error) {
      console.error('Fallback send also failed:', error);
      
      // Last resort: add message locally with real IDs
      this.messages.push({
        id: Date.now(),
        contenu: this.newMessage.trim(),
        date: new Date().toISOString(),
        sender_type: 'therapeute',  // Therapist is sending
        is_read: false,
        patient: this.patientId,  // Use real patient ID
        therapeute: this.therapistId  // Use real therapist ID
      });
      this.newMessage = '';
      this.scrollToBottom();
    }
  }

  setupRealTimeUpdates() {
    // Poll for new messages every 3 seconds
    this.messageInterval = setInterval(() => {
      this.loadMessages();
    }, 3000);
  }

  scrollToBottom() {
    setTimeout(() => {
      if (this.content) {
        this.content.scrollToBottom(300);
      }
    }, 100);
  }

  ionViewWillLeave() {
    if (this.messageInterval) {
      clearInterval(this.messageInterval);
    }
  }

  // Mock data for testing
  loadMockMessages() {
    console.log('Loading mock messages for testing');
    this.messages = [
      {
        id: 1,
        contenu: "Hello! I'm your patient. I'd like to discuss some issues I've been having.",
        date: new Date(Date.now() - 3600000).toISOString(),
        sender_type: 'patient',
        is_read: true,
        patient: this.patientId,
        therapeute: this.therapistId
      },
      {
        id: 2,
        contenu: "Hello! I'm here to help. Please tell me more about what you've been experiencing.",
        date: new Date(Date.now() - 1800000).toISOString(),
        sender_type: 'therapeute',
        is_read: true,
        patient: this.patientId,
        therapeute: this.therapistId
      },
      {
        id: 3,
        contenu: "I've been feeling very anxious about work and having trouble sleeping.",
        date: new Date(Date.now() - 900000).toISOString(),
        sender_type: 'patient',
        is_read: true,
        patient: this.patientId,
        therapeute: this.therapistId
      }
    ];
    this.isLoading = false;
    this.scrollToBottom();
  }

  // Debug method to check current state
  debugState() {
    console.log('=== THERAPIST CHAT DEBUG INFO ===');
    console.log('Patient ID:', this.patientId);
    console.log('Therapist ID:', this.therapistId);
    console.log('Current User:', this.currentUser);
    console.log('Messages count:', this.messages.length);
    console.log('Messages:', this.messages);
    console.log('========================');
  }
  handleKeyPress(event: KeyboardEvent) {
  if (event.key === 'Enter' && !event.shiftKey) {
    event.preventDefault();
    this.sendMessage();
  }
}
}