i = 3;
indbt = indbout{i};
close all
figure
plot(angle_OMR(i,:)*180/pi+OMR_angle)
hold on
plot(angle_tail(i,:)*180/pi+OMR_angle)
plot(indbt(1,:),angle_OMR(i,indbt(1,:))*180/pi+OMR_angle,'ko')
figure
plot(xbody(i,:))
hold on
plot(indbt(1,:),xbody(i,indbt(1,:)),'o')