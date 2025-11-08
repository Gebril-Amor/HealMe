import { ComponentFixture, TestBed } from '@angular/core/testing';
import { HumeursPage } from './humeurs.page';

describe('HumeursPage', () => {
  let component: HumeursPage;
  let fixture: ComponentFixture<HumeursPage>;

  beforeEach(() => {
    fixture = TestBed.createComponent(HumeursPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
