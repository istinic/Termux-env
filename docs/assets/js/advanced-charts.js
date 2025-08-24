<script>
// Advanced Charts & Analytics - Milestone 3.2
// Interactive Chart.js implementation

class TermuxAnalytics {
    constructor() {
        this.charts = {};
        this.data = {};
        this.init();
    }

    async init() {
        console.log('📈 Initializing Advanced Analytics Dashboard...');
        await this.loadData();
        this.createPackageTrendChart();
        this.createStorageDonutChart();  
        this.createSystemHealthRadar();
        this.createComponentStatusBars();
        this.startRealTimeUpdates();
    }

    async loadData() {
        // Simulate loading analytics data
        this.data = {
            packageTrends: {
                labels: this.generateDateLabels(7),
                datasets: [{
                    label: 'Package Count',
                    data: [88, 89, 89, 90, 90, 90, 90],
                    borderColor: '#00d2ff',
                    backgroundColor: 'rgba(0, 210, 255, 0.1)',
                    tension: 0.4,
                    fill: true
                }]
            },
            storageData: {
                used: 42,
                available: 958,
                efficiency: 95.8
            },
            systemHealth: {
                packageManagement: 95,
                dataCollection: 100,
                changeDetection: 92,
                githubActions: 96,
                storageEfficiency: 98
            },
            componentStatus: [
                { name: 'Package Management', value: 95, status: 'excellent' },
                { name: 'Data Collection', value: 100, status: 'perfect' },
                { name: 'Change Detection', value: 92, status: 'good' },
                { name: 'GitHub Actions', value: 96, status: 'excellent' },
                { name: 'Storage Efficiency', value: 98, status: 'excellent' }
            ]
        };
    }

    generateDateLabels(days) {
        const labels = [];
        for (let i = days - 1; i >= 0; i--) {
            const date = new Date();
            date.setDate(date.getDate() - i);
            labels.push(date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }));
        }
        return labels;
    }

    createPackageTrendChart() {
        const ctx = document.getElementById('packageTrendChart');
        if (!ctx) return;

        this.charts.packageTrend = new Chart(ctx, {
            type: 'line',
            data: this.data.packageTrends,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    title: {
                        display: true,
                        text: '📦 Package Installation Trends (7 Days)',
                        color: '#f0f6fc',
                        font: { size: 16, weight: 'bold' }
                    },
                    legend: {
                        labels: { color: '#f0f6fc' }
                    }
                },
                scales: {
                    x: {
                        ticks: { color: '#8b949e' },
                        grid: { color: '#30363d' }
                    },
                    y: {
                        ticks: { color: '#8b949e' },
                        grid: { color: '#30363d' },
                        beginAtZero: false
                    }
                },
                animation: {
                    duration: 2000,
                    easing: 'easeInOutQuart'
                },
                interaction: {
                    intersect: false,
                    mode: 'index'
                }
            }
        });

        console.log('📈 Package trend chart created');
    }

    createStorageDonutChart() {
        const ctx = document.getElementById('storageChart');
        if (!ctx) return;

        this.charts.storage = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: ['Used Storage', 'Available Storage'],
                datasets: [{
                    data: [this.data.storageData.used, this.data.storageData.available],
                    backgroundColor: ['#f72585', '#21262d'],
                    borderColor: ['#f72585', '#30363d'],
                    borderWidth: 2,
                    cutout: '60%'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    title: {
                        display: true,
                        text: '💾 Storage Utilization',
                        color: '#f0f6fc',
                        font: { size: 16, weight: 'bold' }
                    },
                    legend: {
                        position: 'bottom',
                        labels: {
                            color: '#f0f6fc',
                            padding: 20,
                            usePointStyle: true
                        }
                    }
                },
                animation: {
                    animateRotate: true,
                    duration: 2000
                }
            }
        });

        // Add center text for efficiency
        const centerText = {
            id: 'centerText',
            beforeDatasetsDraw: (chart) => {
                const { ctx, chartArea } = chart;
                ctx.save();
                ctx.font = 'bold 18px sans-serif';
                ctx.fillStyle = '#00d2ff';
                ctx.textAlign = 'center';
                ctx.textBaseline = 'middle';
                const centerX = (chartArea.left + chartArea.right) / 2;
                const centerY = (chartArea.top + chartArea.bottom) / 2;
                ctx.fillText(`${this.data.storageData.efficiency}%`, centerX, centerY - 10);
                ctx.font = '12px sans-serif';
                ctx.fillStyle = '#8b949e';
                ctx.fillText('Efficiency', centerX, centerY + 10);
                ctx.restore();
            }
        };

        this.charts.storage.config.plugins.push(centerText);
        console.log('💾 Storage chart created');
    }

    createSystemHealthRadar() {
        const ctx = document.getElementById('healthChart');
        if (!ctx) return;

        const healthData = this.data.systemHealth;
        
        this.charts.health = new Chart(ctx, {
            type: 'radar',
            data: {
                labels: [
                    'Package Management',
                    'Data Collection', 
                    'Change Detection',
                    'GitHub Actions',
                    'Storage Efficiency'
                ],
                datasets: [{
                    label: 'Health Score',
                    data: [
                        healthData.packageManagement,
                        healthData.dataCollection,
                        healthData.changeDetection,
                        healthData.githubActions,
                        healthData.storageEfficiency
                    ],
                    borderColor: '#56d364',
                    backgroundColor: 'rgba(86, 211, 100, 0.2)',
                    pointBackgroundColor: '#56d364',
                    pointBorderColor: '#ffffff',
                    pointBorderWidth: 2,
                    borderWidth: 2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    title: {
                        display: true,
                        text: '🏥 System Health Overview',
                        color: '#f0f6fc',
                        font: { size: 16, weight: 'bold' }
                    },
                    legend: {
                        labels: { color: '#f0f6fc' }
                    }
                },
                scales: {
                    r: {
                        min: 0,
                        max: 100,
                        ticks: { 
                            color: '#8b949e', 
                            stepSize: 20,
                            callback: function(value) {
                                return value + '%';
                            }
                        },
                        grid: { color: '#30363d' },
                        angleLines: { color: '#30363d' },
                        pointLabels: { 
                            color: '#f0f6fc', 
                            font: { size: 11 }
                        }
                    }
                },
                animation: {
                    duration: 2500,
                    easing: 'easeOutBounce'
                }
            }
        });

        console.log('🏥 Health radar chart created');
    }

    createComponentStatusBars() {
        // Enhanced progress bars with animations
        this.data.componentStatus.forEach((component, index) => {
            const bar = document.getElementById(`progress-${index}`);
            if (bar) {
                setTimeout(() => {
                    bar.style.width = `${component.value}%`;
                    bar.className = `progress-fill ${component.status}`;
                }, index * 200);
            }
        });

        console.log('📊 Component status bars animated');
    }

    startRealTimeUpdates() {
        // Simulate real-time updates every 30 seconds
        setInterval(() => {
            this.updateCharts();
        }, 30000);

        console.log('🔄 Real-time updates started');
    }

    updateCharts() {
        // Simulate small data changes
        const now = new Date();
        const timeLabel = now.toLocaleTimeString('en-US', { 
            hour: '2-digit', 
            minute: '2-digit' 
        });

        // Update package trend with small variation
        if (this.charts.packageTrend) {
            const data = this.charts.packageTrend.data;
            data.labels.push(timeLabel);
            data.datasets[0].data.push(90 + Math.floor(Math.random() * 2));