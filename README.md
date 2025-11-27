# AVPlayer

[English](README_EN.md) | [한국어](README.md)

TMDB(The Movie Database) API를 활용한 iOS 영화 정보 앱입니다. 인기 영화 목록 조회, 검색, 상세 정보 확인 및 예고편 재생 기능을 제공합니다.

## 주요 기능

### 🔒 보안
- **패스코드 잠금**: 6자리 숫자 패스코드로 앱 보호
- **Face ID 지원**: 생체 인증을 통한 빠른 잠금 해제
- **랜덤 키패드**: 매번 다른 위치의 숫자 키패드로 보안 강화
- **자동 Face ID**: 설정 시 앱 실행 시 자동으로 Face ID 인증

### 🎬 영화 정보
- **인기 영화 목록**: TMDB API를 통한 실시간 인기 영화 조회
- **영화 검색**: 실시간 검색 기능 (0.5초 디바운싱 적용)
- **무한 스크롤**: 페이지네이션을 통한 부드러운 스크롤 경험
- **영화 상세 정보**: 
  - 포스터 이미지
  - 평점 정보
  - 줄거리 (더보기/접기 기능)
  - 예고편 재생

### 🎥 예고편 재생
- **앱 내 재생**: WKWebView를 사용한 앱 내 YouTube 예고편 재생
- **Safari 연동**: Safari에서 열기 옵션 제공
- **인라인 재생**: 전체 화면 전환 없이 인라인 동영상 재생 지원

### 🖼️ 이미지 최적화
- **이미지 캐싱**: NSCache를 활용한 메모리 캐싱
- **중복 요청 방지**: 동일 이미지에 대한 중복 다운로드 방지
- **자동 취소**: 셀 재사용 시 진행 중인 이미지 다운로드 자동 취소

## 스크린샷

<div align="center">
  
### 잠금 화면
<img width="296" height="640" alt="Image" src="https://github.com/user-attachments/assets/d44896dc-df46-4641-93b2-b005eb569490" />
<img width="296" height="640" alt="Image" src="https://github.com/user-attachments/assets/e0bf1e4f-1f1c-49c1-a535-9c0ffbeeab45" />

### 영화 목록
<img width="296" height="640" alt="Image" src="https://github.com/user-attachments/assets/6c3ddd3d-25ad-409b-9223-b12aa94f5e3b" />

### 영화 검색
<img width="296" height="640" alt="Image" src="https://github.com/user-attachments/assets/8f7d6f73-e79c-4147-b29f-beeb7df608d6" />
<img width="296" height="640" alt="Image" src="https://github.com/user-attachments/assets/c3876c11-357f-40e8-b153-b124f5b9c5a0" />

### 영화 상세 정보
<img width="296" height="640" alt="Image" src="https://github.com/user-attachments/assets/88ee5677-e237-4cd2-9533-7316914c51ff" />
<img width="1320" height="2868" alt="Image" src="https://github.com/user-attachments/assets/085912f8-231f-482c-a3e3-3a8edfb5e9a8" />

### 예고편 재생
<img width="296" height="640" alt="Image" src="https://github.com/user-attachments/assets/4ae5579e-9f1b-49b6-96f6-541aa5d273dc" />
<img width="296" height="640" alt="Image" src="https://github.com/user-attachments/assets/9c48a2ba-f0ff-44a0-94c2-273e1a5b72c8" />

</div>

## 기술 스택

- **언어**: Swift
- **UI 프레임워크**: 
  - UIKit (메인 화면)
  - SwiftUI (패스코드 잠금 화면)
- **네트워킹**: URLSession
- **인증**: LocalAuthentication (Face ID/Touch ID)
- **미디어**: 
  - AVKit
  - WebKit (YouTube 재생)
- **API**: [TMDB (The Movie Database) API](https://www.themoviedb.org/)

## 프로젝트 구조

```
AVPlayer/
├── AppDelegate.swift              # 앱 생명주기 관리
├── SceneDelegate.swift             # Scene 설정 및 잠금 화면 초기화
├── ViewController.swift            # 메인 영화 목록 화면
├── MovieDetailViewController.swift # 영화 상세 정보 화면
├── MovieCell.swift                 # 영화 목록 셀
├── MovieModel.swift                # 영화 데이터 모델
├── NetworkManager.swift            # TMDB API 통신 관리
├── ImageLoader.swift               # 이미지 다운로드 및 캐싱
└── PasscodeLockViewController.swift # 패스코드 잠금 화면 (SwiftUI)
```

## 아키텍처

- **MVC 패턴**: Model-View-Controller 아키텍처 적용
- **싱글톤 패턴**: 
  - `ImageLoader.shared`: 이미지 캐싱 및 로딩 관리
  - `NetworkManager`: 네트워크 통신 관리

## 주요 컴포넌트

### NetworkManager
TMDB API와의 통신을 담당하는 클래스입니다.
- 인기 영화 목록 조회
- 영화 검색
- 예고편 정보 조회
- Bearer Token 인증
- 에러 처리

### ImageLoader
이미지 다운로드 및 캐싱을 관리하는 싱글톤 클래스입니다.
- 메모리 캐싱 (NSCache)
- 중복 다운로드 방지
- 다운로드 취소 기능

### PasscodeLockView
SwiftUI로 구현된 패스코드 잠금 화면입니다.
- 6자리 숫자 패스코드 입력
- Face ID 생체 인증
- 랜덤 키패드 배치
- 햅틱 피드백

## 요구사항

- iOS 13.0 이상
- Xcode 12.0 이상
- Swift 5.0 이상
- 인터넷 연결 (TMDB API 사용)

## 설정 방법

1. **프로젝트 클론**
   ```bash
   git clone [repository-url]
   cd AVPlayer
   ```

2. **Xcode에서 프로젝트 열기**
   - `AVPlayer.xcodeproj` 파일을 Xcode로 엽니다.

3. **TMDB API 키 설정** (선택사항)
   - `NetworkManager.swift`의 `bearerToken`을 본인의 TMDB API 키로 변경할 수 있습니다.
   - 현재는 기본 Bearer Token이 설정되어 있습니다.

4. **빌드 및 실행**
   - 시뮬레이터 또는 실제 기기에서 빌드 및 실행합니다.

## 사용 방법

1. **앱 실행**: 앱을 실행하면 패스코드 잠금 화면이 표시됩니다.
2. **잠금 해제**: 
   - 6자리 패스코드 입력 (기본값: `100712`)
   - 또는 Face ID 버튼을 눌러 생체 인증
3. **영화 탐색**: 
   - 인기 영화 목록을 스크롤하여 탐색
   - 검색바에서 영화 제목 검색
4. **상세 정보 확인**: 영화 포스터를 탭하여 상세 정보 확인
5. **예고편 재생**: 상세 화면에서 "예고편 재생" 버튼을 눌러 YouTube 예고편 시청

## 주요 특징

- ✅ 다크모드 지원
- ✅ 한국어 지원 (TMDB API 한국어 응답)
- ✅ 메모리 효율적인 이미지 캐싱
- ✅ 부드러운 애니메이션 및 전환 효과
- ✅ 네트워크 에러 처리
- ✅ 접근성 지원

## 라이선스

이 프로젝트는 개인 학습 및 포트폴리오 목적으로 제작되었습니다.

## 참고 자료

- [TMDB API 문서](https://developers.themoviedb.org/3)
- [TMDB 이미지 API](https://developers.themoviedb.org/3/getting-started/images)

