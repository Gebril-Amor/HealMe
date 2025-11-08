import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { TherapistChatPage } from './therapist-chat.page';

const routes: Routes = [
  {
    path: '',
    component: TherapistChatPage
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class TherapistChatPageRoutingModule {}
