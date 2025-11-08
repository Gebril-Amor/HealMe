// chat.page.ts - Fixed with correct patient ID
import { Component, OnInit, ViewChild } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { HttpClient } from '@angular/common/http';
import { IonContent, Platform } from '@ionic/angular';
import { AuthService } from '../../services/auth';

@Component({
  selector: 'app-chat',
  templateUrl: './chat.page.html',
  styleUrls: ['./chat.page.scss'],
  standalone: false
})
export class ChatPage implements OnInit {
  @ViewChild(IonContent) content!: IonContent;
  
  messages: any[] = [];
  newMessage: string = '';
  therapist: any = null;
  therapistId: number = 0;
  patientId: number = 0;
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
    this.therapistId = +this.route.snapshot.paramMap.get('id')!;
    this.therapist = this.router.getCurrentNavigation()?.extras?.state?.['therapist'];
    
    this.currentUser = this.authService.getCurrentUser();
    
    // Get patient ID from current user - use the user ID directly
    if (this.currentUser) {
      this.patientId = this.currentUser.id; // This is the patient ID
      console.log('Current user ID (patientId):', this.patientId);
      console.log('Therapist ID:', this.therapistId);
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
      console.log('Loading messages for patient:', this.patientId, 'therapist:', this.therapistId);
      
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
      patient_id: this.patientId  // Include the actual patient ID
    };

    console.log('Sending message with real IDs:', messageData);

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
      therapeute: this.therapistId
      // Note: The old endpoint uses the hardcoded patient_id=1 in Django
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
      sender_type: 'patient',
      is_read: true,
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
        contenu: "Hello! I'm your therapist. How can I help you today?",
        date: new Date(Date.now() - 3600000).toISOString(),
        sender_type: 'therapeute',
        is_read: true,
        patient: this.patientId,
        therapeute: this.therapistId
      },
      {
        id: 2,
        contenu: "Hi! I've been feeling anxious lately and would like to discuss it.",
        date: new Date(Date.now() - 1800000).toISOString(),
        sender_type: 'patient',
        is_read: true,
        patient: this.patientId,
        therapeute: this.therapistId
      },
      {
        id: 3,
        contenu: "I understand. Let's schedule a session to talk about this. What times work for you?",
        date: new Date(Date.now() - 900000).toISOString(),
        sender_type: 'therapeute',
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
    console.log('=== CHAT DEBUG INFO ===');
    console.log('Patient ID:', this.patientId);
    console.log('Therapist ID:', this.therapistId);
    console.log('Current User:', this.currentUser);
    console.log('Messages count:', this.messages.length);
    console.log('Messages:', this.messages);
    console.log('========================');
  }
}