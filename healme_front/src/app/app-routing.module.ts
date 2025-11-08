import { NgModule } from '@angular/core';
import { PreloadAllModules, RouterModule, Routes } from '@angular/router';
import { LoginPage } from './pages/login/login.page';
import { RegisterPage } from './pages/register/register.page';


const routes: Routes = [
  {
    path: '',
    redirectTo: 'login',
    pathMatch: 'full'
  },

  {
    path: 'tabs',
    loadChildren: () => import('./tabs/tabs.module').then((m) => m.TabsPageModule),
  },
  {
    path: 'register',
    loadChildren: () => import('./pages/register/register.module').then( m => m.RegisterPageModule)
  },
  {
    path: 'login',
    loadChildren: () => import('./pages/login/login.module').then( m => m.LoginPageModule)
  },
  {
    path: 'add-data',
    loadChildren: () => import('./pages/add-data/add-data.module').then( m => m.AddDataPageModule)
  },
  {
    path: 'data-list',
    loadChildren: () => import('./pages/data-list/data-list.module').then( m => m.DataListPageModule)
  },
  {
    path: 'therapist-list',
    loadChildren: () => import('./pages/therapist-list/therapist-list.module').then( m => m.TherapistListPageModule)
  },
{
    path: 'chat/:id',  // Make sure this route exists
    loadChildren: () => import('./pages/chat/chat.module').then(m => m.ChatPageModule)
  },
  {
    path: 'therapist-home',
    loadChildren: () => import('./pages/therapist-home/therapist-home.module').then( m => m.TherapistHomePageModule)
  },
  {
    path: 'therapist-chat',
    loadChildren: () => import('./pages/therapist-chat/therapist-chat.module').then( m => m.TherapistChatPageModule)
  },
    {
    path: 'therapist-chat/:id',
    loadChildren: () => import('./pages/therapist-chat/therapist-chat.module').then(m => m.TherapistChatPageModule)
  },
];

@NgModule({
  imports: [
    RouterModule.forRoot(routes, { preloadingStrategy: PreloadAllModules })
  ],
  exports: [RouterModule]
})
export class AppRoutingModule { }
