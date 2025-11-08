import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { IonicModule } from '@ionic/angular';

import { TherapistChatPageRoutingModule } from './therapist-chat-routing.module';

import { TherapistChatPage } from './therapist-chat.page';

@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    IonicModule,
    TherapistChatPageRoutingModule
  ],
  declarations: [TherapistChatPage]
})
export class TherapistChatPageModule {}
